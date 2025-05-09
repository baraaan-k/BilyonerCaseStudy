//
//  MatchDetailViewController.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 7.05.2025.
//


import UIKit
import FirebaseAnalytics

final class MatchDetailViewController: UIViewController {

    private let match: Match
    private let basketViewModel: BetBasketViewModel

    private var selectedOddType: MatchOddType?

    private let ms1Button = UIButton(type: .system)
    private let msxButton = UIButton(type: .system)
    private let ms2Button = UIButton(type: .system)
    private let addButton = UIButton(type: .system)
    

    init(match: Match, basketViewModel: BetBasketViewModel) {
        self.match = match
        self.basketViewModel = basketViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Match Detail"

        setupUI()
        updateButtonTitlesWithOdds()
        sendAnalytics()
    }
    
    private func updateButtonTitlesWithOdds() {
        let ms1Value = match.oddValue(for: .ms1).map { String(format: "%.2f", $0) } ?? "-"
        let msxValue = match.oddValue(for: .msx).map { String(format: "%.2f", $0) } ?? "-"
        let ms2Value = match.oddValue(for: .ms2).map { String(format: "%.2f", $0) } ?? "-"

        ms1Button.setTitle("MS 1 - \(ms1Value)", for: .normal)
        msxButton.setTitle("MS X - \(msxValue)", for: .normal)
        ms2Button.setTitle("MS 2 - \(ms2Value)", for: .normal)
    }


    private func setupUI() {
        
        let headerView = MatchHeaderView(match: match)
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100)
        ])

        
        let infoLabel = UILabel()
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.font = .boldSystemFont(ofSize: 16)

        let date = DateFormatter.iso8601Full.date(from: match.commenceTime) ?? Date()
        let displayDate = DateFormatter.localized.string(from: date)

        infoLabel.text = """
        Match: \(match.homeTeam) vs \(match.awayTeam)
        Time: \(displayDate)
        """

        configureOddButton(ms1Button, title: "MS 1", action: #selector(selectMS1))
        configureOddButton(msxButton, title: "MS X", action: #selector(selectMSX))
        configureOddButton(ms2Button, title: "MS 2", action: #selector(selectMS2))

        let oddsStack = UIStackView(arrangedSubviews: [ms1Button, msxButton, ms2Button])
        oddsStack.axis = .horizontal
        oddsStack.spacing = 12
        oddsStack.distribution = .fillEqually

        addButton.setTitle("Add to Bet Slip", for: .normal)
        addButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        addButton.backgroundColor = UIColor(hex: "#58A85C")
        addButton.tintColor = .white
        addButton.layer.cornerRadius = 8
        addButton.addTarget(self, action: #selector(addToBasket), for: .touchUpInside)

        [infoLabel, oddsStack, addButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),

            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            oddsStack.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 30),
            oddsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            oddsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            oddsStack.heightAnchor.constraint(equalToConstant: 50),

            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func configureOddButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.backgroundColor = .clear
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    @objc private func selectMS1() { updateSelection(.ms1, selectedButton: ms1Button) }
    @objc private func selectMSX() { updateSelection(.msx, selectedButton: msxButton) }
    @objc private func selectMS2() { updateSelection(.ms2, selectedButton: ms2Button) }

    private func updateSelection(_ type: MatchOddType, selectedButton: UIButton) {
        selectedOddType = type
        [ms1Button, msxButton, ms2Button].forEach {
            $0.backgroundColor = .clear
            $0.setTitleColor(.label, for: .normal)
        }
        selectedButton.backgroundColor = .systemGreen.withAlphaComponent(0.3)
        
    }

    @objc private func addToBasket() {
        guard let type = selectedOddType else {
            print("Odd haven't selected.")
            return
        }

        guard let value = match.oddValue(for: type) else {
            print("Odd couldn't find: \(type.rawValue)")
            return
        }

        basketViewModel.add(match: match, oddType: type, oddValue: value)
        navigationController?.popViewController(animated: true)
    }

    private func sendAnalytics() {
        Analytics.logEvent("match_detail_viewed", parameters: [
            "match_id": match.id,
            "home_team": match.homeTeam,
            "away_team": match.awayTeam
        ])
    }
}
