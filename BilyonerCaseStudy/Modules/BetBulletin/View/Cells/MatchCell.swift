//
//  MatchOddType.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 8.05.2025.
//


import UIKit
import RxSwift
import RxCocoa

enum MatchOddType: String {
    case ms1 = "MS 1"
    case msx = "MS X"
    case ms2 = "MS 2"
}

protocol MatchCellDelegate: AnyObject {
    func didSelectOdd(match: Match, oddType: MatchOddType, value: Double)
}

final class MatchCell: UITableViewCell {
    
    static let identifier = "MatchCell"
    private var match: Match?
    weak var delegate: MatchCellDelegate?
    
    private let matchLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 1
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()

    private let oddsStack = UIStackView()
    private var buttons: [UIButton] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        buttons.forEach { $0.backgroundColor = .systemGray6 }
    }
    
    func configure(with match: Match, selectedOddType: MatchOddType?) {
        self.match = match
        matchLabel.text = "\(match.homeTeam) - \(match.awayTeam)"
        
        let date = DateFormatter.iso8601Full.date(from: match.commenceTime) ?? Date()
        let timeString = DateFormatter.localized.string(from: date)
        timeLabel.text = timeString
        
        let h2hMarket = match.bookmakers.first?.markets.first(where: { $0.key == "h2h" })
        
        var ms1 = 0.0, msx = 0.0, ms2 = 0.0
        h2hMarket?.outcomes.forEach { outcome in
            if outcome.name == match.homeTeam {
                ms1 = outcome.price
            } else if outcome.name.lowercased() == "draw" {
                msx = outcome.price
            } else if outcome.name == match.awayTeam {
                ms2 = outcome.price
            }
        }

        let odds = [
            (type: MatchOddType.ms1, value: ms1),
            (type: MatchOddType.msx, value: msx),
            (type: MatchOddType.ms2, value: ms2)
        ]

        odds.enumerated().forEach { index, item in
            let button = buttons[index]
            button.setTitle("\(String(format: "%.2f", item.value))\n\(item.type.rawValue)", for: .normal)
            
            button.tag = index
            if item.type == selectedOddType {
                button.backgroundColor = .systemGreen.withAlphaComponent(0.3)
            } else {
                button.backgroundColor = .systemGray6
            }
        }
    }

    private func setupUI() {
        matchLabel.font = .systemFont(ofSize: 16, weight: .medium)
        matchLabel.numberOfLines = 1
        
        oddsStack.axis = .horizontal
        oddsStack.spacing = 8
        oddsStack.distribution = .fillEqually
        
        for _ in 0..<3 {
            let button = UIButton(type: .system)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.font = .boldSystemFont(ofSize: 14)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .systemGray6
            button.layer.cornerRadius = 8
            button.addTarget(self, action: #selector(oddTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            oddsStack.addArrangedSubview(button)
        }

        let titleStack = UIStackView(arrangedSubviews: [matchLabel, timeLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 2

        let arrowImage = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImage.tintColor = .systemGray2
        arrowImage.setContentHuggingPriority(.required, for: .horizontal)

        let titleRow = UIStackView(arrangedSubviews: [titleStack, arrowImage])
        titleRow.axis = .horizontal
        titleRow.spacing = 8
        titleRow.alignment = .center

        let wrapper = UIStackView(arrangedSubviews: [titleRow, oddsStack])
        wrapper.axis = .vertical
        wrapper.spacing = 8

        contentView.addSubview(wrapper)
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wrapper.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            wrapper.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            wrapper.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            wrapper.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    @objc private func oddTapped(_ sender: UIButton) {
        guard let match = match else { return }
        
        let types: [MatchOddType] = [.ms1, .msx, .ms2]
        let type = types[sender.tag]
        let title = sender.title(for: .normal)?.components(separatedBy: "\n").first ?? "0.0"
        let value = Double(title) ?? 0.0

        let isSameSelection = sender.backgroundColor == UIColor.systemGreen.withAlphaComponent(0.3)

        buttons.forEach { $0.backgroundColor = .systemGray6 }

        if isSameSelection {
            delegate?.didSelectOdd(match: match, oddType: type, value: 0)
        } else {
            sender.backgroundColor = .systemGreen.withAlphaComponent(0.3)
            delegate?.didSelectOdd(match: match, oddType: type, value: value)
        }
    }

}
