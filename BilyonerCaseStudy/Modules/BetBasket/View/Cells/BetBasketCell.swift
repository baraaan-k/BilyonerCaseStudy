//
//  BetBasketCell.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 8.05.2025.
//


import UIKit

final class BetBasketCell: UITableViewCell {

    static let identifier = "BetBasketCell"

    private let matchLabel = UILabel()
    private let predictionLabel = UILabel()
    private let oddLabel = UILabel()
    private let favoriteIcon = UIImageView()
    private let deleteButton = UIButton(type: .system)
    private let stack = UIStackView()

    var onDelete: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with selection: MatchSelection) {
        matchLabel.text = "\(selection.match.homeTeam) - \(selection.match.awayTeam)"
        predictionLabel.text = "Prediction: \(selection.oddType.rawValue)"
        oddLabel.text = "Odd: \(String(format: "%.2f", selection.oddValue))"
        
        favoriteIcon.image = UIImage(systemName: "star.fill")
        favoriteIcon.tintColor = .systemYellow

        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
    }


    private func setupUI() {
        matchLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        predictionLabel.font = .systemFont(ofSize: 14)
        oddLabel.font = .systemFont(ofSize: 14)

        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        let predictionRow = UIStackView(arrangedSubviews: [predictionLabel, oddLabel])
        predictionRow.axis = .horizontal
        predictionRow.distribution = .equalSpacing

        let contentStack = UIStackView(arrangedSubviews: [matchLabel, predictionRow])
        contentStack.axis = .vertical
        contentStack.spacing = 4

        let wrapper = UIStackView(arrangedSubviews: [favoriteIcon, contentStack, deleteButton])
        wrapper.axis = .horizontal
        wrapper.spacing = 12
        wrapper.alignment = .center
        wrapper.distribution = .fill

        favoriteIcon.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoriteIcon.widthAnchor.constraint(equalToConstant: 24),
            favoriteIcon.heightAnchor.constraint(equalToConstant: 24),
            deleteButton.widthAnchor.constraint(equalToConstant: 32),
            deleteButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        contentView.addSubview(wrapper)
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wrapper.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            wrapper.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            wrapper.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            wrapper.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func deleteTapped() {
        onDelete?()
    }


}
