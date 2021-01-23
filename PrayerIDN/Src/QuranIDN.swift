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
        
        public var id: Int
        public var name: String
        public var nameArabic: String
        public var place: String
        public var verses_count: Int
        public var verses: [QuranVerse]
    }
    
    public struct QuranVerse: Equatable {
        public static func == (lhs: QuranIDN.QuranVerse, rhs: QuranIDN.QuranVerse) -> Bool {
            lhs.id == rhs.id
        }
        
        public var id: Int
        public var chapter_id: Int
        public var verse: String
        public var verse_locale: QuranVerseLanguage
    }
    
    public struct QuranVerseLanguage {
        public var indonesia: String?
        public var english: String?
        public var arabic: String?
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
                
                let chapter: QuranChapter = res.buildQuranChapter()
                
                if self.quran.contains(chapter),
                   let index = self.quran.firstIndex(of: chapter) {
                    for verse in chapter.verses {
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
