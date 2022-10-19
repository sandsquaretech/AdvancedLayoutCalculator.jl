# AdvancedLayoutCalculator

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Sandsquare-Tinkerbrain.github.io/AdvancedLayoutCalculator.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Sandsquare-Tinkerbrain.github.io/AdvancedLayoutCalculator.jl/dev/)
[![Build Status](https://github.com/Sandsquare-Tinkerbrain/AdvancedLayoutCalculator.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Sandsquare-Tinkerbrain/AdvancedLayoutCalculator.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Sandsquare-Tinkerbrain/AdvancedLayoutCalculator.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Sandsquare-Tinkerbrain/AdvancedLayoutCalculator.jl)

AdvancedLayoutCalculator, or ALC (like alchemist), is designed to generate a (reasonably) optimal keyboard layout given some text, a keyboard layout, and key position-based weights. An important distinction from other layout optimizers is the ability to consider "shift" as its own separate key -- fast typing involves rolling "shift" + alpha to obtain the captial version, meaning "shift" should be optimized for. Additionally, layers are accounted for.