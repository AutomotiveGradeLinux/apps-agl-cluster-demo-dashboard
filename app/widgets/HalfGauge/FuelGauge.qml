// Copyright (C) 2025 the AGL project contributors
// SPDX-License-Identifier: Apache-2.0

HalfGauge {
    unit: "%"
    primaryColor: "#00FF00"
    iconSource: "/images/fuel-icon.png"

    function progressColor() {
        if (value < (maxValue * 0.1))
            return "red";
        else if (value < (maxValue * 0.25))
            return "yellow";
        else
            return primaryColor;
    }
}