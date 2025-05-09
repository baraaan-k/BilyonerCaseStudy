//
//  BetBasketViewModel.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 7.05.2025.
//


import Foundation
import RxSwift
import RxCocoa
import FirebaseAnalytics

final class BetBasketViewModel {
    let selectedMatches: BehaviorRelay<[MatchSelection]>
    let stake = BehaviorRelay<Int>(value: 1)

    init(selectedMatches: BehaviorRelay<[MatchSelection]>) {
        self.selectedMatches = selectedMatches
    }

    var totalOdds: Observable<Double> {
        selectedMatches
            .map { $0.map(\.oddValue).reduce(1.0, *) }
            .asObservable()
    }

    var potentialWin: Observable<Double> {
        Observable.combineLatest(totalOdds, stake.asObservable()) { odds, stake in
            return odds * Double(stake)
        }
    }

    func clearMatch(_ matchID: String) {
        var current = selectedMatches.value
        current.removeAll { $0.match.id == matchID }
        selectedMatches.accept(current)
    }
    
    func removeMatch(withID id: String) {
        var current = selectedMatches.value
        current.removeAll { $0.match.id == id }
        selectedMatches.accept(current)
    }

    func add(match: Match, oddType: MatchOddType, oddValue: Double) {
        var current = selectedMatches.value
        current.removeAll { $0.match.id == match.id }
        current.append(MatchSelection(match: match, oddType: oddType, oddValue: oddValue))
        selectedMatches.accept(current)
    }

    var couponAmount: Observable<Double> {
        stake
            .map { Double($0) }
            .asObservable()
    }

}

