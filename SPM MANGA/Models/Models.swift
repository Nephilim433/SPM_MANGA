//
//  Models.swift
//  SPM MANGA
//
//  Created by Nephilim  on 1/19/23.
//

import Foundation
import UIKit

struct MainMenuModel {
    let title: String
    let coverURL: String
    let chaptersCount: Int
    let genras: [String]
}



struct MangaDetailModel {
    let title: String
    let coverURL: String
    let chaptersCount: Int
    let volumesCount: Int
    let genras: String
    let description: String
    let directory: String
    let chapters: [Chapter]?
    let author: String
    let status: String
    let translation: String
    let release: Int

    let isTranslated: Bool
    let isFinished: Bool
    
}

struct Chapter {
    let chapterName: String
    let chapterID: String
    let pages : [MangaPage]
}

struct MangaPage {
    let orderIndex: Int
    let url: String
}
