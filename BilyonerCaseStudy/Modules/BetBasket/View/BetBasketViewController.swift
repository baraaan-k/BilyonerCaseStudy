//
//  BetBasketViewController.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 7.05.2025.
//


import UIKit
import RxSwift
import RxCocoa

final class BetBasketViewController: UIViewController {

    private let viewModel: BetBasketViewModel
    private let disposeBag = DisposeBag()
    
    private var matches: [Match] = []
    private var selections: [MatchSelection] = []
    
    private let tableView = UITableView()
    private let totalOddsLabel = UILabel()
    private let totalWinLabel = UILabel()
    private let stakeStepper = UIStepper()
    private let stakeLabel = UILabel()
    private let couponLabel = UILabel()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "🛒 Your bet slip is currently empty.\nSelect a match to start placing bets."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()

    init(viewModel: BetBasketViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Bet Slip"
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        setupSummaryView()
        setupEmptyView()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emptyStateLabel.isHidden = !selections.isEmpty
        tableView.isHidden = selections.isEmpty
    }

    private func setupTableView() {
        tableView.register(BetBasketCell.self, forCellReuseIdentifier: BetBasketCell.identifier)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -160)
        ])

        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupEmptyView() {
        view.addSubview(emptyStateLabel)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])

    }
    
    private func setupSummaryView() {
        totalOddsLabel.font = .boldSystemFont(ofSize: 16)
        totalOddsLabel.text = "Sum Odd: 0.00"

        totalWinLabel.font = .boldSystemFont(ofSize: 16)
        totalWinLabel.textColor = UIColor(hex: "#58A85C")
        totalWinLabel.text = "Potential Win: 0 ₺"

        couponLabel.font = .systemFont(ofSize: 14)
        couponLabel.text = "Total Bet Amount: 0 ₺"

        stakeLabel.font = .systemFont(ofSize: 14)
        stakeLabel.text = "Stake: 1"

        stakeStepper.minimumValue = 1
        stakeStepper.maximumValue = 50
        stakeStepper.value = 1
        stakeStepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)

        let stack = UIStackView(arrangedSubviews: [
            totalOddsLabel,
            stakeLabel,
            couponLabel,
            totalWinLabel,
            stakeStepper
        ])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func stepperChanged() {
        let stake = Int(stakeStepper.value)
        viewModel.stake.accept(stake)
        stakeLabel.text = "Stake: \(stake)"
    }
    
    private func bindViewModel() {
        viewModel.totalOdds
            .map { String(format: "%.2f", $0) }
            .bind(to: totalOddsLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.potentialWin
            .map { "Potential Win: \(String(format: "%.2f", $0)) ₺" }
            .bind(to: totalWinLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.couponAmount
            .map { "Total Bet Amount: \($0) ₺" }
            .bind(to: couponLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.selectedMatches
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.selections = $0
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension BetBasketViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BetBasketCell.identifier, for: indexPath) as? BetBasketCell else {
            return UITableViewCell()
        }
        let selection = selections[indexPath.row]
        cell.configure(with: selection)

        cell.onDelete = { [weak self, weak tableView] in
            guard let self = self, let tableView = tableView else { return }

            let index = indexPath.row
            let matchID = self.selections[index].match.id

            self.selections.remove(at: index)
            self.emptyStateLabel.isHidden = !self.selections.isEmpty
            tableView.isHidden = self.selections.isEmpty
            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
            tableView.endUpdates()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.viewModel.removeMatch(withID: matchID)
            }
        }
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
