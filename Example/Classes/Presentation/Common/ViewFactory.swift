//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools

protocol ViewFactoryOutput {
}

final class ViewFactory {

    typealias ImageQualitiesViewFaftory = ViewCellItemsFactory<ImageQualitiesViewState, ImageQualitiesView>
    typealias ColorViewFaftory = ViewCellItemsFactory<ColorViewState, ColorView>
    typealias ButtonsViewFaftory = ViewCellItemsFactory<ButtonsViewState, ButtonsView>
    typealias SpaceViewFaftory = ViewCellItemsFactory<SpaceViewState, UIView>
    typealias ImageViewFaftory = ViewCellItemsFactory<ImageViewState, UIImageView>
    typealias SliderViewFaftory = ViewCellItemsFactory<SliderViewState, SliderView>
    typealias SegmentedControlViewFaftory = ViewCellItemsFactory<SegmentedControlViewState, SegmentedControlView>

    private(set) lazy var factory: ComplexCellItemsFactory = imageQualitiesViewFaftory
        .factory(byJoining: colorViewFaftory)
        .factory(byJoining: buttonsViewFactory)
        .factory(byJoining: spaceViewFactory)
        .factory(byJoining: imageViewFactory)
        .factory(byJoining: sliderViewFactory)
        .factory(byJoining: segmentedControlViewFaftory)

    private(set) lazy var imageQualitiesViewFaftory: ImageQualitiesViewFaftory = {
        let factory = ImageQualitiesViewFaftory()
        factory.sizeTypesConfigurationHandler = { _ in
            .init(width: .fill, height: .fixed(200))
        }
        factory.viewConfigurationHandler = { view, cellItem in
            DispatchQueue.main.async {
                view.lowQualityImageView.image = cellItem.object.low
                view.normalQualityImageView.image = cellItem.object.normal
                view.highQualityImageView.image = cellItem.object.high
            }
        }
        return factory
    }()

    private(set) lazy var colorViewFaftory: ColorViewFaftory = {
        let factory = ColorViewFaftory()
        factory.sizeTypesConfigurationHandler = { _ in
            .init(width: .fill, height: .fixed(160))
        }
        factory.viewInitialConfigurationHandler = { view, cellItem in
            view.colorDidChangeHandler = { color in
                cellItem.object.color = color
            }
        }
        factory.viewConfigurationHandler = { view, cellItem in
            view.titleLabel.text = cellItem.object.name
            view.hslView.color = cellItem.object.color

            if let color = cellItem.object.color {
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0

                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                view.sliderView.slider.value = Float(alpha)
            }
            else {
                view.sliderView.slider.value = 1
            }
        }
        return factory
    }()

    private(set) lazy var buttonsViewFactory: ButtonsViewFaftory = {
        let factory = ButtonsViewFaftory()
        factory.sizeTypesConfigurationHandler = { _ in
            .init(width: .fill, height: .fixed(56))
        }
        factory.viewConfigurationHandler = { view, cellItem in
            view.buttonConfigurations = cellItem.object.configurations
        }
        return factory
    }()

    private(set) lazy var spaceViewFactory: SpaceViewFaftory = {
        let factory = SpaceViewFaftory()
        factory.sizeTypesConfigurationHandler = { cellItem in
            .init(width: .fill, height: .fixed(cellItem.object.height))
        }
        factory.viewConfigurationHandler = { view, cellItem in
        }
        return factory
    }()

    private(set) lazy var imageViewFactory: ImageViewFaftory = {
        let factory = ImageViewFaftory()
        factory.sizeTypesConfigurationHandler = { cellItem in
            .init(width: .fill, height: .fixed(200))
        }
        factory.viewConfigurationHandler = { view, cellItem in
            view.image = cellItem.object.image
        }
        return factory
    }()

    private(set) lazy var sliderViewFactory: SliderViewFaftory = {
        let factory = SliderViewFaftory()
        factory.sizeTypesConfigurationHandler = { cellItem in
            .init(width: .fill, height: .fixed(56))
        }
        factory.viewInitialConfigurationHandler = { view, cellItem in
            view.valueDidChangeHandler = { value in
                cellItem.object.value = value
            }
        }
        factory.viewConfigurationHandler = { view, cellItem in
            view.label.text = cellItem.object.name
            view.slider.minimumValue = cellItem.object.min
            view.slider.maximumValue = cellItem.object.max
            view.slider.value = cellItem.object.value
        }
        return factory
    }()

    private(set) lazy var segmentedControlViewFaftory: SegmentedControlViewFaftory = {
        let factory = SegmentedControlViewFaftory()
        factory.sizeTypesConfigurationHandler = { cellItem in
            .init(width: .fill, height: .fixed(56))
        }
        factory.viewInitialConfigurationHandler = { view, cellItem in
            view.selectedIndexDidChangeHandler = { index in
                cellItem.object.index = index
            }
        }
        factory.viewConfigurationHandler = { view, cellItem in
            view.label.text = cellItem.object.name
            view.segmentedControl.removeAllSegments()
            for i in 0..<cellItem.object.cases.count {
                view.segmentedControl.insertSegment(withTitle: cellItem.object.cases[i], at: i, animated: false)
            }
        }
        return factory
    }()

    func makeSectionItems(viewStates: [Any]) -> [CollectionViewDiffSectionItem] {
        let cellItems = factory.makeCellItems(objects: viewStates)
        let sectionItem = GeneralCollectionViewDiffSectionItem(cellItems: cellItems)
        sectionItem.insets = .init(top: 16, left: 16, bottom: 16, right: 16)
        return [sectionItem]
    }
}
