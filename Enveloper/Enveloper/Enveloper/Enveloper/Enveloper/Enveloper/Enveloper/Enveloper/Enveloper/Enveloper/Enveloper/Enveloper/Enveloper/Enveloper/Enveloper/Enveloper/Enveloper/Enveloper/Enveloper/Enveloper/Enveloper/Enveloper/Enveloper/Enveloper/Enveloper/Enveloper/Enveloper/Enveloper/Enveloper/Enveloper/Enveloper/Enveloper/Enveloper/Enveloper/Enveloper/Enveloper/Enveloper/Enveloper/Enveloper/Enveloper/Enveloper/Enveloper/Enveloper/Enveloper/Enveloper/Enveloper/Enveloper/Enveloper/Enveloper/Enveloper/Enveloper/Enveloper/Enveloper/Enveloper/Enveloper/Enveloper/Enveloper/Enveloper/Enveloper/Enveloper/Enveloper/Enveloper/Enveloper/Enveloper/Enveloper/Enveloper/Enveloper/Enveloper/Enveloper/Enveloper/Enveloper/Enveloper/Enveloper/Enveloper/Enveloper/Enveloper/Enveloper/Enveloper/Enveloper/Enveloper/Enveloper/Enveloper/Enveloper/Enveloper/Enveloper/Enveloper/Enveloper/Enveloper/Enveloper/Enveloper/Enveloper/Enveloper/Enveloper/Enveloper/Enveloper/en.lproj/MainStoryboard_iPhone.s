<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="1.0" toolsVersion="1931" systemVersion="11C42" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" initialViewController="3">
    <dependencies>
        <development defaultVersion="4200" identifier="xcode"/>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="928"/>
    </dependencies>
    <scenes>
        <scene sceneID="11">
            <objects>
                <placeholder placeholderIdentifier="IBFirstResponder" id="10" sceneMemberID="firstResponder"/>
                <navigationController id="3" sceneMemberID="viewController">
                    <navigationBar key="navigationBar" opaque="NO" clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="scaleToFill" id="4">
                        <autoresizingMask key="autoresizingMask"/>
                    </navigationBar>
                    <connections>
                        <segue destination="12" kind="relationship" relationship="rootViewController" id="19"/>
                    </connections>
                </navigationController>
            </objects>
            <point key="canvasLocation" x="-1" y="64"/>
        </scene>
        <scene sceneID="18">
            <objects>
                <placeholder placeholderIdentifier="IBFirstResponder" id="17" sceneMemberID="firstResponder"/>
                <tableViewController storyboardIdentifier="" title="Master" id="12" customClass="MasterViewController" sceneMemberID="viewController">
                    <tableView key="view" opaque="NO" clipsSubviews="YES" clearsContextBeforeDrawing="NO" contentMode="scaleToFill" alwaysBounceVertical="YES" dataMode="prototypes" style="plain" rowHeight="44" sectionHeaderHeight="22" sectionFooterHeight="22" id="13">
                        <rect key="frame" x="0.0" y="64" width="320" height="416"/>
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <color key="backgroundColor" white="1" alpha="1" colorSpace="calibratedWhite"/>
                        <prototypes>
                            <tableViewCell contentMode="scaleToFill" selectionStyle="blue" accessoryType="disclosureIndicator" hidesAccessoryWhenEditing="NO" indentationLevel="1" indentationWidth="0.0" reuseIdentifier="Cell" textLabel="rV2-7n-EJo" style="IBUITableViewCellStyleDefault" id="lJ0-d7-vTF">
                                <rect key="frame" x="0.0" y="22" width="320" height="44"/>
                                <autoresizingMask key="autoresizingMask"/>
                                <view key="contentView" opaque="NO" clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="center">
                                    <rect key="frame" x="0.0" y="0.0" width="300" height="43"/>
                                    <autoresizingMask key="autoresizingMask"/>
                                    <subviews>
                                        <label opaque="NO" clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="center" text="Title" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" id="rV2-7n-EJo">
                                            <rect key="frame" x="10" y="0.0" width="280" height="43"/>
                                            <autoresizingMask key="autoresizingMask"/>
                                            <color key="backgroundColor" red="1" green="1" blue="1" alpha="1" colorSpace="calibratedRGB"/>
                                            <fontDescription key="fontDescription" type="boldSystem" pointSize="20"/>
                                            <color key="textColor" cocoaTouchSystemColor="darkTextColor"/>
                                            <color key="highlightedColor" red="1" green="1" blue="1" alpha="1" colorSpace="calibratedRGB"/>
                                        </label>
                                    </subviews>
                                    <color key="backgroundColor" white="0.0" alpha="0.0" colorSpace="calibratedWhite"/>
                                </view>
                                <color key="backgroundColor" white="1" alpha="1" colorSpace="calibratedWhite"/>
                                <connections>
                                    <segue destination="21" kind="push" identifier="showDetail" id="jZb-fq-zAk"/>
                                </connections>
                            </tableViewCell>
                        </prototypes>
                        <sections/>
                        <connections>
                            <outlet property="dataSource" destination="12" id="16"/>
                            <outlet property="delegate" destination="12" id="15"/>
                        </connections>
                    </tableView>
                    <navigationItem key="navigationItem" title="Master" id="36"/>
                </tableViewController>
            </objects>
            <point key="canvasLocation" x="459" y="64"/>
        </scene>
        <scene sceneID="24">
            <objects>
                <placeholder placeholderIdentifier="IBFirstResponder" id="23" sceneMemberID="firstResponder"/>
                <viewController storyboardIdentifier="" title="Detail" id="21" customClass="DetailViewController" sceneMemberID="viewController">
                    <view key="view" contentMode="scaleToFill" id="22">
                        <rect key="frame" x="0.0" y="64" width="320" height="416"/>
                        <autoresizingMask key="autoresizingMask" flexibleMaxX="YES" flexibleMaxY="YES"/>
                        <subviews>
                            <label clipsSubviews="YES" userInteractionEnabled="NO" contentMode="scaleToFill" text="Detail view content goes here" textAlignment="center" lineBreakMode="tailTruncation" minimumFontSize="10" id="27">
                                <rect key="frame" x="20" y="199" width="280" height="18"/>
                                <autoresizingMask key="autoresizingMask" widthSizable="YES" flexibleMinY="YES" flexibleMaxY="YES"/>
                                <color key="backgroundColor" white="1" alpha="1" colorSpace="calibratedWhite"/>
                                <fontDescription key="fontDescription" type="system" size="system"/>
                                <color key="textColor" cocoaTouchSystemColor="darkTextColor"/>
                                <nil key="highlightedColor"/>
                            </label>
                        </subviews>
                        <color key="backgroundColor" white="1" alpha="1" colorSpace="custom" customColorSpace="calibratedWhite"/>
                    </view>
                    <navigationItem key="navigationItem" title="Detail" id="26"/>
                    <connections>
                        <outlet property="detailDescriptionLabel" destination="27" id="28"/>
                    </connections>
                </viewController>
            </objects>
            <point key="canvasLocation" x="902" y="64"/>
        </scene>
    </scenes>
    <simulatedMetricsContainer key="defaultSimulatedMetrics">
        <simulatedStatusBarMetrics key="statusBar"/>
        <simulatedOrientationMetrics key="orientation"/>
        <simulatedScreenMetrics key="destination"/>
    </simulatedMetricsContainer>
</document>