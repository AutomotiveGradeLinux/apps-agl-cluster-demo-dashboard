// Copyright (C) 2024, 2025 the AGL project contributors
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.9

Item {
    id: root
    width: 200
    height: 200

    property real value: 0
    property real minValue: 0
    property real maxValue: 100
    property string unit: ""
    property string iconSource: ""

    property color primaryColor: "#16CCBA"
    property color secondaryColor: "#00000000"
    property color backgroundColor: "#00000000"
    property real startAngle: Math.PI * 5 / 4
    property real fullAngle: Math.PI * 1 / 2
    property int ticks: 4
    property real needleScale: 2

    // Calculated based on widget size
    property real gaugeRadius: 0
    property real tickLength: 0

    Component.onCompleted: {
        calculateGeometry();
        updateGaugeValue(value); // Initialize the gauge display
    }

    onWidthChanged: calculateGeometry()
    onHeightChanged: calculateGeometry()

    function calculateGeometry() {
        const side = Math.min(width, height);
        gaugeRadius = side / 2 * 0.95;
        tickLength = gaugeRadius * 0.2;
    }

    function progressColor() {
        return primaryColor;
    }

    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        z: -1
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            var center = Qt.point(width / 2, height / 2);
            var side = Math.min(width, height);
            var progressAngle = startAngle + (value / (maxValue - minValue)) * fullAngle;

            ctx.reset();

            // Background arc
            ctx.lineWidth = 25;
            ctx.beginPath();
            ctx.arc(center.x, center.y, gaugeRadius, startAngle, startAngle + fullAngle);
            ctx.strokeStyle = '#000000';
            ctx.stroke();

            // Fill arc
            ctx.lineWidth = 14;
            ctx.beginPath();
            ctx.arc(center.x,
                    center.y,
                    gaugeRadius - ctx.lineWidth / 2,
                    startAngle,
                    progressAngle);
            ctx.strokeStyle = progressColor();
            ctx.stroke();

            // Draw tick marks
            ctx.lineWidth = tickLength / 3;
            ctx.strokeStyle = '#FFFFFF';
            ctx.lineCap = 'round';
            ctx.beginPath();
            
            for (let i = 0; i <= ticks; i++) {
                const angle = startAngle + (i / ticks) * fullAngle;
                const x1 = center.x + gaugeRadius * Math.cos(angle);
                const y1 = center.y + gaugeRadius * Math.sin(angle);
                const x2 = center.x + (gaugeRadius - tickLength) * Math.cos(angle);
                const y2 = center.y + (gaugeRadius - tickLength) * Math.sin(angle);
                ctx.moveTo(x1, y1);
                ctx.lineTo(x2, y2);
            }
            
            ctx.stroke();

            // Draw progress tick mark
            drawProgressTick(ctx, center, progressAngle);
        }

        function drawProgressTick(ctx, center, angle) {
            ctx.lineWidth = tickLength * 0.45; // Thickness of the progress tick mark
            ctx.strokeStyle = '#FFFFFF'; // Color of the progress tick mark
            ctx.beginPath();

            const x1 = center.cx + gaugeRadius * Math.cos(angle);
            const y1 = center.y + gaugeRadius * Math.sin(angle);
            const x2 = center.x + (gaugeRadius - tickLength * needleScale) * Math.cos(angle); // Adjust length as needed
            const y2 = center.y + (gaugeRadius - tickLength * needleScale) * Math.sin(angle);

            ctx.moveTo(x1, y1);
            ctx.lineTo(x2, y2);
            ctx.stroke();
        }
    }

    Image {
        visible: iconSource != ""
        source: iconSource
        anchors.verticalCenter: gaugeText.verticalCenter
        anchors.right: gaugeText.left
        anchors.rightMargin: 8
        height: 0.12 * Math.min(root.width, root.height)
        fillMode: Image.PreserveAspectFit
        antialiasing: true
    }

    Text {
        id: gaugeText
        anchors.centerIn: parent
        text: "0"
        font.pixelSize: 0.15 * Math.min(root.width, root.height)
        font.bold: true
        color: "#FFFFFF"
    }

    Text {
        id: gaugeUnit
        anchors.verticalCenter: gaugeText.verticalCenter
        anchors.left: gaugeText.right
        text: unit
        font.pixelSize: 0.12 * Math.min(root.width, root.height)
        font.bold: true
        color: "#FFFFFF"
    }

    onValueChanged: updateGaugeValue(value)

    function updateGaugeValue(value) {
        canvas.requestPaint(); // Request a repaint to reflect changes.
        gaugeText.text = value.toFixed(0); // Display the current value directly.
    }
}