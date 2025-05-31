//
//  ViewController.swift
//  SmoothOutlinedLabelDemo
//
//  Created by xwh on 2025/5/31.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var xibLabel: SmoothOutlinedLabel!
    
    var text: String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ 长沙市广播电视台《长沙新闻》20250528期主要内容： 1.吴桂英在望城区调研大泽湖片区建设、文科旅医融合发展等工作 放大特色优势 强化创新赋能 不断激发高质量发展动力活力 2.全国粮食和物资储备科技活动周 紧扣“科技+人才” 多维度筑牢粮食安全“双支柱” 3.粮食科普乡村行走进长沙县 助力节粮减损 4.陈刚督导包保单位食品安全工作 充分发挥各界监督作用 携手筑牢校园食品安全防线 5.长沙市青年人才创新创业政策推介活动在上海举行 背起双肩包出发 创业就业到长沙 6.长沙 2025新一线城市第8位 7.中非经贸总部基地项目部分建成开放 8.2025长沙市金融支持农村产权流转交易推介会举行 9.总编辑调查丨从《铸剑志》到《夫人如见》　见人物 见好戏 见长沙文艺传承创新 10.2025年“心思政”融合创新故事分享会举行 助力未成年人阳光成长 11.长沙发布“三考”静音倡议书 为广大考生营造安静舒适的考试和休息环境 12.长沙新增477家省级专精特新中小企业"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        testCode()
        
        testXib(self.xibLabel)

    }

    func testCode() {
        self.view.layoutIfNeeded()
        
        let label = SmoothOutlinedLabel(frame: CGRect(x: 20, y: 120, width: self.view.frame.size.width-40, height: 280))
        view.addSubview(label)

        label.text = self.text
        label.strokeColor = .red
        label.textColor = .white
        label.strokeWidth = 5
        label.backgroundColor = .clear
        label.lineLimit = 0
        label.letterSpacing = 1
        
        label.shadowColor = UIColor.black.withAlphaComponent(0.25)
        label.shadowOffset = CGSize(width: 2, height: 4)
        label.shadowBlur = 8.0
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    func testXib(_ label: SmoothOutlinedLabel) {

        label.text = self.text
        label.shadowColor = UIColor.black.withAlphaComponent(0.25)
        label.shadowOffset = CGSize(width: 2, height: 4)
        label.shadowBlur = 8.0
        
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.strokeColor = .green
        label.strokeWidth = 5
        label.textColor = .white
    }

}

