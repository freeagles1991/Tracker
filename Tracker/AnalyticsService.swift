//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Дима on 23.09.2024.
//

import Foundation
import AppMetricaCore

struct AnalyticsEvent {
    let eventType: AnalyticsEventType
    let screen: String
    let item: AanaliticsClickEventType?
}

enum AnalyticsEventType: String {
    case open
    case close
    case click
}

enum AanaliticsClickEventType: String {
    case add_track
    case track
    case filter
    case edit
    case delete
}

final class AnalyticsService {
    func sendEvent(_ analyticsEvent: AnalyticsEvent) {
        var params: [AnyHashable: Any] = [
            "event": analyticsEvent.eventType.rawValue,
            "screen": analyticsEvent.screen
        ]
        
        if let item = analyticsEvent.item {
            params["item"] = item.rawValue
        }
        
        AppMetrica.reportEvent(name: analyticsEvent.eventType.rawValue, parameters: params, onFailure: { error in
                print("DID FAIL REPORT EVENT: \(error.localizedDescription)")
        })
    }
}

