//
//  PopularMatchCellDelegate.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 8.05.2025.
//


import UIKit

protocol PopularMatchCellDelegate: AnyObject {
    func didSelectPopularOdd(match: Match, oddType: MatchOddType, value: Double)
}

final class PopularMatchCell: UICollectionViewCell {
    
    static let identifier = "PopularMatchCell"
    weak var delegate: PopularMatchCellDelegate?
    private var match: Match?

    private let matchLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()

    private var buttons: [UIButton] = []
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
        setupLayout()
        contentView.backgroundColor = .clear
        contentView.layer.borderWidth = 0.8
        contentView.layer.borderColor = UIColor(hex: "#58A85C").cgColor
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = .clear
        }
    }

    private func setupButtons() {
        for index in 0..<3 {
            let button = UIButton(type: .system)
            button.tag = index
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.layer.cornerRadius = 6
            button.layer.borderColor = UIColor.systemGray4.cgColor
            button.layer.borderWidth = 1
            button.titleLabel?.font = .boldSystemFont(ofSize: 12)
            button.setTitleColor(.black, for: .normal)
            button.addTarget(self, action: #selector(oddButtonTapped(_:)), for: .touchUpInside)
            buttons.append(button)
        }
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillEqually

        let titleStack = UIStackView(arrangedSubviews: [matchLabel, timeLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 2

        let mainStack = UIStackView(arrangedSubviews: [titleStack, stack])
        mainStack.axis = .vertical
        mainStack.spacing = 6
        
        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with match: Match, selectedOddType: MatchOddType?) {
        let isoFormatter = ISO8601DateFormatter()
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy - HH:mm"

        if let date = isoFormatter.date(from: match.commenceTime) {
            timeLabel.text = "Match Time: \(outputFormatter.string(from: date))"
        } else {
            timeLabel.text = "Match Time: -"
        }
        
        self.match = match
        matchLabel.text = "\(match.homeTeam) - \(match.awayTeam)"

        let h2h = match.bookmakers.first?.markets.first(where: { $0.key == "h2h" })
        var ms1 = 0.0, msx = 0.0, ms2 = 0.0
        h2h?.outcomes.forEach { outcome in
            if outcome.name == match.homeTeam {
                ms1 = outcome.price
            } else if outcome.name.lowercased() == "draw" {
                msx = outcome.price
            } else if outcome.name == match.awayTeam {
                ms2 = outcome.price
            }
        }

        let odds: [(MatchOddType, Double)] = [
            (.ms1, ms1),
            (.msx, msx),
            (.ms2, ms2)
        ]

        for (index, (type, value)) in odds.enumerated() {
            let button = buttons[index]
            let title = "\(String(format: "%.2f", value))\n\(type.rawValue)"
            button.setTitle(title, for: .normal)
            button.backgroundColor = (type == selectedOddType) ? UIColor.systemGreen.withAlphaComponent(0.3) : UIColor.systemGray6
        }
    }

    @objc private func oddButtonTapped(_ sender: UIButton) {
        guard let match = match else { return }
        let types: [MatchOddType] = [.ms1, .msx, .ms2]
        let type = types[sender.tag]
        let parts = sender.titleLabel?.text?.components(separatedBy: "\n") ?? []
        if parts.count == 2, let value = Double(parts[0]) {
            delegate?.didSelectPopularOdd(match: match, oddType: type, value: value)
        }
    }
}
