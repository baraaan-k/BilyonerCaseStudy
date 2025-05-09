//
//  MatchHeaderView.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 8.05.2025.
//

import UIKit

final class MatchHeaderView: UIView {

    private let homeImageView = UIImageView()
    private let awayImageView = UIImageView()
    private let homeLabel = UILabel()
    private let awayLabel = UILabel()
    private let leagueLabel = UILabel()
    private let matchTimeLabel = UILabel()
    private let centerStack = UIStackView()

    init(match: Match) {
        super.init(frame: .zero)
        setupUI(match: match)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(match: Match) {
        homeImageView.contentMode = .scaleAspectFit
        awayImageView.contentMode = .scaleAspectFit

        homeImageView.image = UIImage(named: "barca")
        awayImageView.image = UIImage(named: "realmadrid")

        homeLabel.text = match.homeTeam
        homeLabel.font = .boldSystemFont(ofSize: 14)
        homeLabel.textAlignment = .center

        awayLabel.text = match.awayTeam
        awayLabel.font = .boldSystemFont(ofSize: 14)
        awayLabel.textAlignment = .center

        leagueLabel.text = match.sportTitle
        leagueLabel.font = .systemFont(ofSize: 12)
        leagueLabel.textAlignment = .center
        leagueLabel.textColor = .secondaryLabel

        let date = DateFormatter.iso8601Full.date(from: match.commenceTime) ?? Date()
        matchTimeLabel.text = DateFormatter.localized.string(from: date)
        matchTimeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        matchTimeLabel.textAlignment = .center

        centerStack.axis = .vertical
        centerStack.alignment = .center
        centerStack.spacing = 4
        centerStack.addArrangedSubview(leagueLabel)
        centerStack.addArrangedSubview(matchTimeLabel)

        let hStack = UIStackView(arrangedSubviews: [
            createTeamStack(imageView: homeImageView, label: homeLabel),
            centerStack,
            createTeamStack(imageView: awayImageView, label: awayLabel)
        ])
        hStack.axis = .horizontal
        hStack.spacing = 20
        hStack.distribution = .equalCentering
        hStack.alignment = .center

        addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    private func createTeamStack(imageView: UIImageView, label: UILabel) -> UIStackView {
        imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }
}
