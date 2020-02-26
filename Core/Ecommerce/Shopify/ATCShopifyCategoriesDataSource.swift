//
//  ATCShopifyCategoriesDataSource.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 3/17/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import MobileBuySDK

class ATCShopifyCategoriesDataSource: ATCGenericCollectionViewControllerDataSource {
    
    let shopDomain: String
    let apiKey: String
    let client: Graph.Client
    
    init(shopDomain: String, apiKey: String) {
        self.shopDomain = shopDomain
        self.apiKey = apiKey
        self.client = Graph.Client(
            shopDomain: shopDomain,
            apiKey: apiKey
        )
    }
    
    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < categories.count {
            return categories[index]
        }
        return nil
    }
    
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    var categories: [Category] = []

    var collectionCursor: String?
    
    func numberOfObjects() -> Int {
        return categories.count
    }

    func loadFirst() {
        let query = Storefront.buildQuery { $0
            .shop { $0
                .collections(first: 10, after: collectionCursor) { $0
                    .pageInfo { $0
                        .hasNextPage()
                    }
                    .edges { $0
                        .node { $0
                            .id()
                            .title()
                            .image { $0
                            .originalSrc()
                            }
                        }
                    .cursor()
                    }
                }
            }
        }

        let task = client.queryGraphWith(query) { response, error in
            let collections  = response?.shop.collections.edges.map { $0.node }
            self.collectionCursor = response?.shop.collections.edges.last?.cursor
            let hasNextPage = response?.shop.collections.pageInfo.hasNextPage ?? false
            if hasNextPage || (self.collectionCursor != nil) {
                self.loadFirst()
            }
            collections?.forEach { collection in
                let image: String = collection.image?.originalSrc.absoluteString ?? ""
                self.categories.append(Category(title: collection.title,
                                                colorString: "",
                                                id: collection.id.rawValue,
                                                imageURLString: image))
            }
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: self.categories)
        }
        task.resume()
    }

    func loadBottom() {

    }

    func loadTop() {
        
    }

}
