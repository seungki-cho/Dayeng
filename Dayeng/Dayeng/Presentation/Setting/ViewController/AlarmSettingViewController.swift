//
//  AlarmSettingViewController.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/06.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AlarmSettingViewController: UIViewController {
    // MARK: - UI properties
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.cgColor
        return view
    }()
    
    private lazy var titleLable: UILabel = {
        let label = UILabel()
        label.text = "알람"
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .bold)
        
        return label
    }()
    
    private lazy var discriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "설정한 시간에 오늘의 질문을 알려드려요."
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        
        return label
    }()
    
    private lazy var switchButton: UISwitch = {
        let switchButton = UISwitch()
        
        return switchButton
    }()
    
    private lazy var hiddenContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        
        return view
    }()
    
    private lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.locale = Locale(identifier: "ko-KR")
        picker.preferredDatePickerStyle = .wheels
        
        return picker
    }()
    
    private lazy var daysOfWeek: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.backgroundColor = CGColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        let tapGestureRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGestureRecognizer)
        daysOfWeekDidTapped = tapGestureRecognizer.rx.event.map { _ in }.asObservable()
        return view
    }()
    
    private lazy var dayTitleView: UILabel = {
        let label = UILabel()
        label.text = "요일"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .regular)
        
        return label
    }()
    
    private lazy var dayListLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        
        return label
    }()
    
    private lazy var registButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.layer.cornerRadius = 10
        button.layer.backgroundColor = CGColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        button.setTitleColor(UIColor(red: 102/255, green: 103/255, blue: 171/255, alpha: 1.0), for: .normal)
        
        return button
    }()
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    let viewModel: AlarmSettingViewModel
    var daysOfWeekDidTapped: Observable<Void>!
    
    // MARK: - Lifecycles
    init(alarmSettingViewModel: AlarmSettingViewModel) {
        self.viewModel = alarmSettingViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
    }
    
    // MARK: - Helpers
    
    private func setupViews() {
        addBackgroundImage()
        view.addSubview(contentView)
        contentView.addSubview(titleLable)
        contentView.addSubview(discriptionLabel)
        contentView.addSubview(switchButton)
        contentView.addSubview(hiddenContentView)
        hiddenContentView.addSubview(timePicker)
        hiddenContentView.addSubview(daysOfWeek)
        daysOfWeek.addSubview(dayTitleView)
        daysOfWeek.addSubview(dayListLabel)
        hiddenContentView.addSubview(registButton)
    }
    
    private func configureUI() {
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(100)
        }
        
        titleLable.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.top.equalToSuperview().inset(20)
        }
        
        discriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.top.equalTo(titleLable.snp.bottom).offset(15)
        }
        
        switchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15)
            $0.top.equalToSuperview().inset(20)
        }
        
        hiddenContentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(discriptionLabel.snp.bottom).offset(20)
            $0.height.equalTo(300)
        }
        
        timePicker.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(150)
        }
        
        daysOfWeek.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(timePicker.snp.bottom).offset(20)
            $0.height.equalTo(50)
        }
        
        dayTitleView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
            $0.top.bottom.equalToSuperview().inset(15)
        }
        
        dayListLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.top.bottom.equalToSuperview().inset(15)
        }
        
        registButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(daysOfWeek.snp.bottom).offset(50)
            $0.height.equalTo(50)
        }
        
        switchButton.rx.isOn
            .subscribe(onNext: { [weak self] isOn in
                guard let self else { return }
                self.showSwitchAnimation(isOn)
            }).disposed(by: disposeBag)
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "알람 설정"
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    private func bind() {
        let input = AlarmSettingViewModel.Input(
            viewWillAppear:
                rx.methodInvoked(#selector(viewWillAppear(_:))).map { _ in }.asObservable(),
            viewDidAppear:
                rx.methodInvoked(#selector(viewDidAppear(_:))).map { _ in }.asObservable(),
            registButtonDidTapped:
                registButton.rx.tap.map { self.timePicker.date },
            daysOfWeekDidTapped:
                daysOfWeekDidTapped,
            isAlarmSwitchOn:
                switchButton.rx.isOn.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.isAlarmOn
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isOn in
                guard let self else { return }
                self.switchButton.isOn = isOn
            }).disposed(by: disposeBag)
        
        output.dayList
            .asDriver(onErrorJustReturn: "안 함")
            .drive(onNext: { [weak self] dayList in
                guard let self else { return }
                self.dayListLabel.text = dayList
            }).disposed(by: disposeBag)
        
        output.setDate
            .asDriver(onErrorJustReturn: Date())
            .drive(onNext: { [weak self] date in
                guard let self else { return }
                self.timePicker.date = date
            }).disposed(by: disposeBag)
        
        output.isSuccessRegistResult
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isSuccess in
                guard let self else { return }
                if isSuccess {
                    self.showAlert(title: "알림 설정이 완료되었습니다.", type: .oneButton)
                } else {
                    self.showAlert(title: "알림 서비스를 사용할 수 없습니다.",
                                   message: "기기의 '설정 > Dayeng'에서\n 알림 접근을 허용해주세요.",
                                   type: .twoButton,
                                   rightActionTitle: "설정으로 이동",
                                   rightActionHandler: {
                        guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(settingURL)
                    })
                    self.showSwitchAnimation(false)
                }
            }).disposed(by: disposeBag)
    }
    
    private func showSwitchAnimation(_ isOn: Bool) {
        if isOn {
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let self else { return }
                self.contentView.snp.updateConstraints {
                    $0.height.equalTo(450)
                }
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.hiddenContentView.isHidden = false
            }
        } else {
            self.hiddenContentView.isHidden = true
            
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let self else { return }
                self.contentView.snp.updateConstraints {
                    $0.height.equalTo(100)
                }
                self.view.layoutIfNeeded()
            }
        }
    }
}
