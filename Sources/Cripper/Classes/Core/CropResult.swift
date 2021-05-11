//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit

/// Specifies a status of crop applying
public enum CropResult {
    /// Could not retrieve cropped image
    case undefined
    /// Could retrieve cropped image
    case normal(UIImage)
    /// Could retrieve cropped image with invalid applying context
    case forced(UIImage)
}
