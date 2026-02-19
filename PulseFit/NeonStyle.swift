//
//  NeonStyle.swift
//  PulseFit
//
//  Created by Camilo Montero on 2026-02-18.
//

import SwiftUI

enum Neon {
    // Core palette (tuned to your reference)
    static let bg0 = Color(red: 0.04, green: 0.05, blue: 0.07)        // near-black
    static let bg1 = Color(red: 0.07, green: 0.08, blue: 0.11)        // deep slate
    static let card = Color.white.opacity(0.06)                       // glass fill
    static let stroke = Color.white.opacity(0.10)                     // subtle border
    static let neon = Color(red: 0.78, green: 0.97, blue: 0.25)       // lime accent
    static let muted = Color.white.opacity(0.70)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [bg1, bg0],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct NeonCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Neon.stroke, lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 10)
    }
}

extension View {
    func neonCard() -> some View { modifier(NeonCard()) }

    func neonScreenBackground() -> some View {
        self
            .background(Neon.backgroundGradient.ignoresSafeArea())
            .tint(Neon.neon)
    }

    func neonPill(selected: Bool) -> some View {
        self
            .font(.subheadline.weight(.semibold))
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Capsule(style: .continuous)
                    .fill(selected ? Neon.neon.opacity(0.18) : Color.white.opacity(0.06))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(selected ? Neon.neon.opacity(0.35) : Neon.stroke, lineWidth: 1)
                    )
            )
            .foregroundStyle(selected ? Color.white : Neon.muted)
    }

    func neonPrimaryButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(Color.black)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Neon.neon)
                    .shadow(color: Neon.neon.opacity(0.25), radius: 18, x: 0, y: 10)
            )
    }

    func neonSecondaryButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(Color.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Neon.stroke, lineWidth: 1)
                    )
            )
    }
}
