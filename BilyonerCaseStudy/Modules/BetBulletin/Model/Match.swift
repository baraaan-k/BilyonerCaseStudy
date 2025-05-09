//
//  Match.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 7.05.2025.
//


import Foundation

struct Match: Codable {
    let id: String
    let sportTitle: String
    let commenceTime: String
    let homeTeam: String
    let awayTeam: String
    let bookmakers: [Bookmaker]

    enum CodingKeys: String, CodingKey {
        case id
        case sportTitle = "sport_title"
        case commenceTime = "commence_time"
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case bookmakers
    }
}

extension Match {
    func oddValue(for type: MatchOddType) -> Double? {
        guard let outcomes = bookmakers.first?.markets.first?.outcomes else { return nil }

        let targetName: String
        switch type {
        case .ms1: targetName = homeTeam
        case .msx: targetName = "Draw"
        case .ms2: targetName = awayTeam
        }

        return outcomes.first(where: {
            $0.name.caseInsensitiveCompare(targetName) == .orderedSame
        })?.price
    }
}

struct Bookmaker: Codable {
    let markets: [Market]
}

struct Market: Codable {
    let key: String
    let outcomes: [Outcome]
}

struct Outcome: Codable {
    let name: String
    let price: Double
}
