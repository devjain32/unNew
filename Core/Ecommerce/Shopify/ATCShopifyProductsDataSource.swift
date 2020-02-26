//
//  ATCShopifyProductsDataSource.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 3/17/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import MobileBuySDK

class ATCShopifyProductsDataSource: ATCGenericCollectionViewControllerDataSource {
    
    let shopDomain: String
    let apiKey: String
    let categoryId: String
    let client: Graph.Client
    
    init(shopDomain: String, apiKey: String, categoryId: String) {
        self.shopDomain = shopDomain
        self.apiKey = apiKey
        self.categoryId = categoryId
        self.client = Graph.Client(
            shopDomain: shopDomain,
            apiKey: apiKey
        )
    }
    
    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < products.count {
            return products[index]
        }
        return nil
    }
    
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    var products: [Product] = []

    var productCursor: String?
    
    func numberOfObjects() -> Int {
        return products.count
    }
 
    func loadFirst() {
        guard !categoryId.isEmpty else {
            self.products = []
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: self.products)
            return
        }
        let query = Storefront.buildQuery { $0
            .node(id: GraphQL.ID(rawValue: categoryId)) { $0
                .onCollection { $0
                    .products(first: 10, after: productCursor) { $0
                        .pageInfo { $0
                            .hasNextPage()
                        }
                        .edges { $0
                            .cursor()
                            .node { $0
                                .id()
                                .title()
                                .productType()
                                .description()
                                .images(first: 10) { $0
                                    .edges { $0
                                        .node { $0
                                            .id()
                                            .src()
                                        }
                                    }
                                }
                                .variants(first: 10) { $0
                                    .edges { $0
                                        .node { $0
                                            .id()
                                            .price()
                                            .title()
                                            .available()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        let task = client.queryGraphWith(query) { response, error in
            let collections  = response?.node as? Storefront.Collection
            let products  = collections?.products.edges.map { $0.node }
            self.productCursor = collections?.products.edges.last?.cursor
            products?.forEach { product in
                let images   = product.images.edges.map { $0.node }
                let variants = product.variants.edges.map { $0.node }
                let price: String = ((variants.count ?? 0) > 0) ? String(describing: (variants[0].price as? Decimal) ?? 0) : "0"
                let image: String = ((images.count ?? 0) > 0) ? images[0].src.absoluteString ?? "" : ""
                self.products.append(Product(title: product.title,
                                             price: price,
                                             images: [image],
                                             colors: [],
                                             sizes: [],
                                             id: product.id.rawValue,
                                             imageURLString: image,
                                             productDescription: product.description))
            }
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: self.products)
            if collections?.products.pageInfo.hasNextPage ?? false {
                self.loadFirst()
            }
        }
        task.resume()
    }

    func loadBottom() {

    }

    func loadTop() {
        
    }

}
