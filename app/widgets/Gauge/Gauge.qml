// Copyright (C) 2024, 2025 the AGL project contributors
// SPDX-License-Identifier: Apache-2.0

import QtQuick
import QtQuick.Shapes 1.9

Item {
    id: root
    width: 200
    height: 200

    property real value: 0
    property real minValue: 0
    property real maxValue: 100
    property string unit: ""

    property color primaryColor: "#16ccba"
    property color secondaryColor: "#00000000"
    property color backgroundColor: "#00000000"
    property color borderColor: "#a6fffa"
    property bool showValueText: false
    property real valueTextScale: 0.2
    property bool showUnitText: true
    property real unitTextSize: 18
    property real startAngle: Math.PI * 3 / 4
    property real fullAngle: Math.PI * 3 / 2
    property int ticks: 10
    property real needleScale: 2.5

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
        gaugeRadius = side / 2 * 0.8;
        tickLength = gaugeRadius * 0.1;
    }

    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        z: -2
    }

    // It may be worth investigating combining this with drawBorder
    // in the Canvas below. Using a non-transparent stroke here did
    // not quite work as desired, as it is not obvious how to keep
    // the gradient from extending slightly past the stroke.
    // It seems possible that not doing this in the Canvas may be
    // slightly more performant, though.
    Shape {
        anchors.fill: parent
        opacity: 0.45
        z: -1

        ShapePath {
            id: p1
            strokeColor: "transparent"
            readonly property real r: Math.min(width, height) / 2

            fillGradient: RadialGradient {
                centerX: width / 2
                centerY: height / 2
                centerRadius: p1.r
                focalX: centerX
                focalY: centerY
                GradientStop { position: 0; color: "#09111e" }
                GradientStop { position: 0.8; color: "#09111e" }
                GradientStop { position: 1.0; color: "#a6fffa" }
            }

            PathAngleArc {
                centerX: width / 2
                centerY: height / 2
                radiusX: p1.r
                radiusY: p1.r
                sweepAngle: 360
            }
        }
    }

    Image {
        // Decorative ticks
        id: background
        source: "./assets/Ellipse 1.svg"
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        scale: 1
        opacity: 0.7
        z: 0
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            var center = Qt.point(width / 2, height / 2);

            ctx.reset();
            drawBorder(ctx, center);
            drawTickBackground(ctx, center);
            drawProgress(ctx, center, value);
            drawTicks(ctx, center);
            drawProgressTick(ctx, center, value);
        }

        function drawBorder(ctx, center) {
            let radius = Math.min(width, height) / 2;
            let lineWidth = 3;
            ctx.lineWidth = lineWidth;
            radius -= lineWidth / 2;
            ctx.lineCap = "round";
            ctx.beginPath();
            ctx.arc(center.x,
                    center.y,
                    radius,
                    0,
                    2 * Math.PI);
            ctx.strokeStyle = borderColor;
            ctx.stroke();
        }

        function drawTickBackground(ctx, center) {
            ctx.lineWidth = gaugeRadius * 0.1;
            ctx.lineCap = "butt";
            ctx.beginPath();
            ctx.arc(center.x, center.y, gaugeRadius, startAngle, startAngle + fullAngle);
            ctx.strokeStyle = secondaryColor;
            ctx.stroke();
        }

        function drawProgress(ctx, center, progress) {
            ctx.lineWidth = 20;
            ctx.lineCap = "butt";
            let progressOffset = ctx.lineWidth / 2;

            var gradient = ctx.createLinearGradient(
                center.x - gaugeRadius,
                center.y,
                center.x + gaugeRadius,
                center.y
            );

            gradient.addColorStop(0.6, primaryColor);
            gradient.addColorStop(0.8, "#FFD700");
            gradient.addColorStop(1, "#FF0000");

            ctx.beginPath();
            ctx.arc(center.x,
                    center.y,
                    gaugeRadius - progressOffset,
                    startAngle,
                    startAngle + (progress / (maxValue - minValue)) * fullAngle);
            ctx.strokeStyle = gradient;
            ctx.stroke();
        }

        function drawTicks(ctx, center) {
            ctx.lineWidth = tickLength / 3;
            ctx.strokeStyle = '#FFFFFF';
            ctx.lineCap = "round";
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
        }

        function drawProgressTick(ctx, center, progress) {
            ctx.lineWidth = tickLength / 2;
            ctx.strokeStyle = '#FFFFFF';
            ctx.lineCap = "round";
            ctx.beginPath();

            const progressAngle = startAngle + (progress / (maxValue - minValue)) * fullAngle;
            const x1 = center.x + gaugeRadius * Math.cos(progressAngle);
            const y1 = center.y + gaugeRadius * Math.sin(progressAngle);
            const x2 = center.x + (gaugeRadius - tickLength * needleScale) * Math.cos(progressAngle);
            const y2 = center.y + (gaugeRadius - tickLength * needleScale) * Math.sin(progressAngle);

            ctx.moveTo(x1, y1);
            ctx.lineTo(x2, y2);
            ctx.stroke();
        }
    }

    Rectangle {
        id: gaugeTextBox
        height: parent.height / 3
        width: parent.width / 2
        color: backgroundColor
        anchors.centerIn: parent

        Text {
            id: gaugeText
            visible: showValueText
            anchors.centerIn: parent
            //Layout.alignment: Qt.AlignCenter
            //Layout.bottomMargin: 0
            text: "0"
            font.pixelSize: valueTextScale * Math.min(root.width, root.height)
            font.bold: true
            color: "#FFFFFF"
        }
    }

    Text {
        id: gaugeUnit
        visible: showUnitText
        //anchors.top: gaugeText.bottom
        //anchors.horizontalCenter: gaugeText.horizontalCenter
        anchors.top: gaugeTextBox.bottom
        anchors.horizontalCenter: gaugeTextBox.horizontalCenter
        //Layout.alignment: Qt.AlignCenter
        //Layout.topMargin: 0
        text: unit
        font.pixelSize: unitTextSize
        font.bold: true
        color: "#FFFFFF"
    }

    onValueChanged: updateGaugeValue(value)

    function updateGaugeValue(value) {
       canvas.requestPaint(); // Request a repaint to reflect changes.
       gaugeText.text = (value).toFixed(0); // Display the current value directly.
   }
}
