// Copyright (C) 2025 the AGL project contributors
// SPDX-License-Identifier: Apache-2.0

HalfGauge {
    maxValue: 120
    unit: "°C"
    primaryColor: "#00FF00"
    iconSource: "/images/carbon_icons/temperature--water.svg"

    function progressColor() {
        if (value > (maxValue * 0.625))
            return "yellow";
        else if (value > (maxValue * 0.75))
            return "red";
        else
            return primaryColor;
    }
}