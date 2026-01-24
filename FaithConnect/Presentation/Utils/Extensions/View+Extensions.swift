//
//  View+Extensions.swift
//  FaithConnect
//
//  Created by hansol on 2025/11/16.
//

import SwiftUI

extension View {
    func customBackButtonStyle() -> some View {
        modifier(CustomBackButtonStyle<EmptyView>(trailingButton: nil))
    }
    
    func customBackButtonStyle<Trailing: View>(
          @ViewBuilder trailingButton: () -> Trailing
      ) -> some View {
          modifier(
              CustomBackButtonStyle(
                  trailingButton: trailingButton()
              )
          )
      }
}
