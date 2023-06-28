//
//  ContentView.swift
//  PokemonAnimation
//
//  Created by Joshua Homann on 6/24/23.
//

import Observation
import SwiftUI

@Observable
@MainActor
final class PokemonViewModel {
    private(set) var pokemon: [Pokemon] = []
    nonisolated init() { }
    func callAsFunction() async {
        do {
            pokemon = try await Pokemon.all
        } catch {
            print(error)
        }
    }
}

enum PokemonAnimationPhase: CaseIterable, Hashable {
    case rest, squash, jump, relax
    var scale: CGSize {
        switch self {
        case .rest, .relax: CGSize(width: 1, height: 1)
        case .squash: CGSize(width: 1.3, height: 0.66)
        case .jump: CGSize(width: 0.66, height: 1.3)
        }
    }
    var anchor: UnitPoint {
        switch self {
        case .rest, .relax, .jump: .center
        case .squash: .bottom
        }
    }
    var offset: Double {
        switch self {
        case .rest, .relax: 0
        case .jump: -100
        case .squash: 10
        }
    }
    var animation: Animation? {
        switch self {
        case .rest: nil
        case .jump: .bouncy
        case .relax: .smooth
        case .squash: .snappy
        }
    }
}

struct PokemonAnimationKeyedValues {
    var scale = 1.0
    var offset = 0.0
}

struct PokemonImageView: View {
    @State private var phaseAnimate = false
    @State private var keyframeAnimate = false
    var pokemon: Pokemon
    var body: some View {
        AsyncImage(
            url: pokemon.artURL,
            content: { image in
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
            },
            placeholder: {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Material.regular)
            })
        .onTapGesture {
            phaseAnimate.toggle()
        }
        .gesture(DragGesture().onEnded { _ in keyframeAnimate.toggle() })
        .keyframeAnimator(
            initialValue: PokemonAnimationKeyedValues(),
            trigger: keyframeAnimate
        ) { content, value in
            content
                .scaleEffect(value.scale)
                .offset(x: value.offset)
        } keyframes: { value in
            KeyframeTrack(\.scale) {
                CubicKeyframe(2, duration: 0.5)
                CubicKeyframe(0.5, duration: 0.1)
                CubicKeyframe(1.5, duration: 0.1)
                CubicKeyframe(0.8, duration: 0.1)
                CubicKeyframe(1.2, duration: 0.1)
                CubicKeyframe(1.0, duration: 0.1)            }
            KeyframeTrack(\.offset) {
                SpringKeyframe(-100, duration: 0.5)
                SpringKeyframe(100, duration: 0.5)
                SpringKeyframe(-10, duration: 0.5)
                SpringKeyframe(10, duration: 0.5)
                SpringKeyframe(0, duration: 0.5)
            }
        }
        .phaseAnimator(
            PokemonAnimationPhase.allCases,
            trigger: phaseAnimate
        ) { content, phase in
            content
                .scaleEffect(phase.scale, anchor: phase.anchor)
                .offset(y: phase.offset)
        }
    }
}

struct ContentView: View {
    private let viewModel = PokemonViewModel()
    var body: some View {
        NavigationSplitView {
            List(viewModel.pokemon) { pokemon in
                Text(pokemon.name)
            }
        } detail: {
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(viewModel.pokemon) { pokemon in
                        PokemonImageView(pokemon: pokemon)
                            .containerRelativeFrame(.horizontal, count: 7, span: 3, spacing: 8)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
        }
        .task { await viewModel() }
    }
}

#Preview {
    ContentView()
}
