//
//  QuranWorker.swift
//  PrayerIDN
//
//  Created by Rangga Leo on 21/01/21.
//

import Foundation

internal class QuranWorker {
    static let shared = QuranWorker()
    
    
    func getQuran(surahNumber: Int? = nil, ayahNumber: [Int] = [], language: [QuranLanguage] = [], completion: @escaping (Result<QuranResponse, Error>, _ urlString: String) -> Void) {
        var url = URLConstant.api_quran + "surat"
        
        if let surah = surahNumber {
            let surahStr = String(describing: surah)
            url = url + "/" + surahStr
        }
        
        if ayahNumber.count > 0 {
            let mutatingAyahs = ayahNumber.sorted()
            let ayahStrings: [String] = mutatingAyahs.map{( String(describing: $0) )}
            let ayahStr = ayahStrings.joined(separator: ",")
            url = url + "/ayat/" + ayahStr
        }
        
        if language.count > 0 {
            let langStrings: [String] = language.map({ $0.rawValue })
            let langStr = langStrings.joined(separator: ",")
            url = url + "/bahasa/" + langStr
        }
        
        let disk = DiskStorage()
        let storage = CodableStorage(storage: disk)
        storage.fetch(for: url, object: QuranResponse.self) { (result) in
            switch result {
            case .failure(let err):
                debugLog(err)
                HTTPRequest.shared.connect(url: url, params: nil, model: QuranResponse.self) { (result) in
                    completion(result, url)
                    return
                }
                
            case .success(let res):
                let response: Result<QuranResponse, Error> = .success(res)
                completion(response, url)
                return
            }
        }
    }
}

public enum QuranLanguage: String, Codable {
    case al // albenian
    case ar // arabic
    case az // azerbaijani
    case en // english
    case tl // english transliteration
    case fr // french
    case de // germany
    case id // indonesia
    case idt // indonesia transliterasi
}

struct QuranResponse: Codable {
    let status: String
    let query: RequestQuery
    let bahasa: QuranLanguageRequest
    let surat: QuranSurat
    let ayat: QuranAyatRequest
}

struct QuranLanguageRequest: Codable {
    let proses: [QuranLanguage]
    let keterangan: [String]
}

struct QuranSurat: Codable {
    let nomor, nama, asma, name: String
    let start, ayat, type, urut: String
    let rukuk, arti, keterangan: String
}

struct QuranAyatRequest: Codable {
    let proses: [Int]
    let error: [Int]?
    let data: QuranAyatLanguage
}

struct QuranAyatLanguage: Codable {
    let al: [QuranAyat]? // albenian
    let ar: [QuranAyat]? // arabic
    let az: [QuranAyat]? // azerbaijani
    let en: [QuranAyat]? // english
    let tl: [QuranAyat]? // english transliteration
    let fr: [QuranAyat]? // french
    let de: [QuranAyat]? // germany
    let id: [QuranAyat]? // indonesia
    let idt: [QuranAyat]? // indonesia transliterasi
}

struct QuranAyat: Codable {
    let id, surat, ayat, teks: String
}

extension QuranResponse {
    func buildQuranChapter() -> QuranIDN.QuranChapter {
        let res = self
        var chapter: QuranIDN.QuranChapter = QuranIDN.QuranChapter(id: 0, name: "", nameArabic: "", place: "", verses_count: 0, verses: [])
        
        if let chapter_id = Int(res.surat.nomor),
           let verseCount = Int(res.surat.ayat) {
            chapter.id = chapter_id
            chapter.verses_count = verseCount
            chapter.name = res.surat.name
            chapter.nameArabic = res.surat.asma
            chapter.place = res.surat.type
        }
        
        var verses: [QuranIDN.QuranVerse] = []
        let totalRequestAyat = res.ayat.proses.count - 1
        
        for index in 0...totalRequestAyat {
            var quranLang = QuranIDN.QuranVerseLanguage(indonesia: nil, english: nil, arabic: nil)
            var verse = QuranIDN.QuranVerse(id: 0, chapter_id: 0, verse: "", verse_locale: quranLang)

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
        return chapter
    }
}

