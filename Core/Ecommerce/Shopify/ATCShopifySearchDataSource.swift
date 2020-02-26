//
//  ATCShopifySearchDataSource.swift
//  Shopertino
//
//  Created by Mac  on 19/11/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import MobileBuySDK

class ATCShopifySearchDataSource<T: ATCGenericSearchable & ATCGenericBaseModel>: ATCGenericSearchViewControllerDataSource {

    var viewer: ATCUser?
    weak var delegate: ATCGenericSearchViewControllerDataSourceDelegate?
    
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

    var products: [Product] = []
    
    var productCursor: String?

    var currentSearchTask: Task?

    func search(text: String?) {
        if let currentSearchTask = currentSearchTask {
            currentSearchTask.cancel()
        }
        self.productCursor = nil
        self.products.removeAll()
        self.fetchShopifyProducts(text: text, productCursor: nil)
    }
    
    func fetchShopifyProducts(text: String?, productCursor: String?) {
        let query = Storefront.buildQuery { $0
            .shop { $0
                .products(first: 10, after: productCursor, query:text) { $0
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

        let task = client.queryGraphWith(query) { response, error in
            let products  = response?.shop.products.edges.map { $0.node }
            self.productCursor = response?.shop.products.edges.last?.cursor
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
            self.delegate?.dataSource(self as ATCGenericSearchViewControllerDataSource, didFetchResults: self.products)
            if response?.shop.products.pageInfo.hasNextPage ?? false {
                self.fetchShopifyProducts(text: text, productCursor: self.productCursor)
            }
        }
        task.resume()
        currentSearchTask = task
    }
    
    func update(completion: @escaping () -> Void) {}
}
