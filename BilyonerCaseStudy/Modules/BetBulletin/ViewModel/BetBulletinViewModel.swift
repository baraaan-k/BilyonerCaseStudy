//
//  BetBulletinViewModel.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 7.05.2025.
//


import Foundation
import RxSwift
import RxCocoa

final class BetBulletinViewModel {
    
    let matches = BehaviorRelay<[Match]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    
    let searchQuery = BehaviorRelay<String>(value: "")
    let filteredMatches = BehaviorRelay<[Match]>(value: [])
    
    func bindSearch() {
        Observable.combineLatest(matches, searchQuery)
            .map { matches, query in
                guard !query.isEmpty else { return matches }
                return matches.filter {
                    $0.homeTeam.lowercased().contains(query.lowercased()) ||
                    $0.awayTeam.lowercased().contains(query.lowercased())
                }
            }
            .bind(to: filteredMatches)
            .disposed(by: disposeBag)
    }
    
    
    func fetchMatches() {
        isLoading.accept(true)
        
        APIClient.shared.request(
            .upcomingEvents(sport: "soccer_epl", region: "eu"),
            responseType: [Match].self
        ) { [weak self] result in
            guard let self = self else { return }
            self.isLoading.accept(false)
            
            switch result {
            case .success(let data):
                self.matches.accept(data)
                self.bindSearch()
            case .failure(let err):
                self.error.accept("Veri alınamadı: \(err)")
            }
        }
    }
    
    let selectedMatches = BehaviorRelay<[MatchSelection]>(value: [])
    
    func selectOdd(for match: Match, oddType: MatchOddType, value: Double) {
        var selections = selectedMatches.value
        
        if let index = selections.firstIndex(where: { $0.match.id == match.id }) {
            let existing = selections[index]
            
            if existing.oddType == oddType {
                selections.remove(at: index)
            } else {
                selections[index] = MatchSelection(match: match, oddType: oddType, oddValue: value)
            }
        } else {
            selections.append(MatchSelection(match: match, oddType: oddType, oddValue: value))
        }
        
        selectedMatches.accept(selections)
    }
    
    
    
    
    
}


