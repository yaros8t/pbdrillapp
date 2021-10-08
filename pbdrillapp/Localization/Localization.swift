//
//  Localization.swift
//  pbdrillapp
//
//  Created by Yaros T on 08.10.2021.
//  Copyright © 2021 Yaros8T. All rights reserved.
//

import Foundation

extension String {
    public var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
