//
//  QuranIDN.swift
//  PrayerIDN
//
//  Created by Rangga Leo on 21/01/21.
//

import Foundation

public protocol QuranIDNDelegate: class {
    func didGetVerse(chapter: QuranIDN.QuranChapter)
    func failGetVerse(error: Error)
    func didGetChapter(chapters: [QuranIDN.QuranChapter])
    func failGetChapter(error: Error)
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
    
    public init() {}
    
    public func getChapter(chapter_id: Int? = nil) {
        QuranWorker.shared.getSurah(surahNumber: chapter_id) { (result, urlstring) in
            switch result {
            case .failure(let error):
                self.delegate?.failGetChapter(error: error)
                
            case .success(let res):
                let disk = DiskStorage()
                let storage = CodableStorage(storage: disk)
                try? storage.save(res, for: urlstring)
                
                let chapters: [QuranChapter] = res.buildQuranChapter()
                self.delegate?.didGetChapter(chapters: chapters)
            }
        }
    }
    
    public func getVerse(chapter_id: Int, verse_ids: [Int], language: [QuranLanguage] = []) {
        QuranWorker.shared.getAyat(surahNumber: chapter_id, ayahNumber: verse_ids, language: language) { (result, urlstring) in
            switch result {
            case .failure(let error):
                self.delegate?.failGetVerse(error: error)
                
            case .success(let res):
                let disk = DiskStorage()
                let storage = CodableStorage(storage: disk)
                try? storage.save(res, for: urlstring)
                
                let chapter: QuranChapter = res.buildQuranVerse()
                self.delegate?.didGetVerse(chapter: chapter)
            }
        }
    }
}
