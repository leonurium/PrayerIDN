//
//  QuranIDN.swift
//  PrayerIDN
//
//  Created by Rangga Leo on 21/01/21.
//

import Foundation

public protocol QuranIDNDelegate: class {
    func failRequest(error: Error)
    func didGetQuran(result: [QuranIDN.QuranChapter])
}

public class QuranIDN {
    public struct QuranChapter: Equatable {
        public static func == (lhs: QuranIDN.QuranChapter, rhs: QuranIDN.QuranChapter) -> Bool {
            lhs.id == rhs.id
        }
        
        var id: Int
        var name: String
        var nameArabic: String
        var place: String
        var verses_count: Int
        var verses: [QuranVerse]
    }
    
    public struct QuranVerse: Equatable {
        public static func == (lhs: QuranIDN.QuranVerse, rhs: QuranIDN.QuranVerse) -> Bool {
            lhs.id == rhs.id
        }
        
        var id: Int
        var chapter_id: Int
        var verse: String
        var verse_locale: QuranVerseLanguage
    }
    
    public struct QuranVerseLanguage {
        var indonesia: String?
        var english: String?
        var arabic: String?
    }
    
    public weak var delegate: QuranIDNDelegate?
    private var quran: [QuranChapter] = []
    
    public init(surahNumber: Int? = nil, ayahNumber: [Int] = [], language: [QuranLanguage] = []) {
        QuranWorker.shared.getQuran(surahNumber: surahNumber, ayahNumber: ayahNumber, language: language) { (result, urlstring) in
            switch result {
            case .failure(let err):
                self.delegate?.failRequest(error: err)
                
            case .success(let res):
                let disk = DiskStorage()
                let storage = CodableStorage(storage: disk)
                try? storage.save(res, for: urlstring)
                
                var chapter: QuranChapter = QuranChapter(id: 0, name: "", nameArabic: "", place: "", verses_count: 0, verses: [])
                
                if let chapter_id = Int(res.surat.nomor),
                   let verseCount = Int(res.surat.ayat) {
                    chapter.id = chapter_id
                    chapter.verses_count = verseCount
                    chapter.name = res.surat.name
                    chapter.nameArabic = res.surat.asma
                    chapter.place = res.surat.type
                }
                
                var verses: [QuranVerse] = []
                let totalRequestAyat = res.ayat.proses.count - 1
                
                for index in 0...totalRequestAyat {
                    var quranLang = QuranVerseLanguage(indonesia: nil, english: nil, arabic: nil)
                    var verse = QuranVerse(id: 0, chapter_id: 0, verse: "", verse_locale: quranLang)

                    if let ayat = res.ayat.data.id?[safe: index],
                       let ayat_id = Int(ayat.ayat),
                       let surah_id = Int(ayat.surat) {
                        quranLang.indonesia = ayat.teks
                        verse.id = ayat_id
                        verse.chapter_id = surah_id
                    }
                    
                    if let ayat = res.ayat.data.en?[safe: index],
                       let ayat_id = Int(ayat.ayat),
                       let surah_id = Int(ayat.surat) {
                        quranLang.english = ayat.teks
                        verse.id = ayat_id
                        verse.chapter_id = surah_id
                    }
                    
                    if let ayat = res.ayat.data.ar?[safe: index],
                       let ayat_id = Int(ayat.ayat),
                       let surah_id = Int(ayat.surat) {
                        quranLang.arabic = ayat.teks
                        verse.id = ayat_id
                        verse.chapter_id = surah_id
                        verse.verse = ayat.teks
                    }
                    verse.verse_locale = quranLang
                    verses.append(verse)
                }
                
                chapter.verses.append(contentsOf: verses)
                if self.quran.contains(chapter),
                   let index = self.quran.firstIndex(of: chapter) {
                    for verse in verses {
                        if !self.quran[index].verses.contains(verse) {
                            self.quran[index].verses.append(verse)
                        }
                    }
                    
                    self.quran[index].verses.sort(by: {
                        $0.id < $1.id
                    })
                    
                } else {
                    self.quran.append(chapter)
                }
                
                self.quran.sort(by: {
                    $0.id < $1.id
                })
                
                self.delegate?.didGetQuran(result: self.quran)
            }
        }
    }
}
