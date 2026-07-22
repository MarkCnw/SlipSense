//
//  MailView.swift
//  SlipSense
//
//  Created by MarkCnw on 7/20/26.
//


import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    
    // ตั้งค่าพื้นฐานสำหรับอีเมล
    let toRecipients: [String]
    let subject: String
    let messageBody: String

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool

        init(isShowing: Binding<Bool>) {
            _isShowing = isShowing
        }

        // ฟังก์ชันนี้จะทำงานเมื่อผู้ใช้กด "ส่ง" หรือ "ยกเลิก"
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            // สั่งให้ปิดหน้าต่างป๊อปอัป
            isShowing = false
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(toRecipients)
        vc.setSubject(subject)
        vc.setMessageBody(messageBody, isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        
    }
}
