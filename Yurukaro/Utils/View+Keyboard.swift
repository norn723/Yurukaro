//
//  View+Keyboard.swift
//  Yurukaro
//
//  Created by 衛藤唯花  on 2026/04/18.
//

import SwiftUI

/// どの画面からでもキーボードを閉じるための拡張
extension View {

    /// キーボードを閉じる処理
    /// ボタン押下時などに呼び出す
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
