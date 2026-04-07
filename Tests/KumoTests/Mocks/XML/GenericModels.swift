// Generic domain models for XML decoding tests.
// Uses fictional domains (weather, e-commerce, employee directory, metrics)
// to exercise KumoCoding XMLDecoder edge cases without referencing
// any internal or proprietary systems.
//
// NOTE: Properties use PascalCase with explicit CodingKeys so that
// KeyedXMLDecodingContainer.contains() and decodeNil(forKey:) — which
// both match by exact stringValue — work correctly with the XML element
// names.  This follows the same convention used by the existing
// HeaderConfiguration and SearchResult mock models.
import Foundation

// MARK: - Weather Forecast (nested optionals, multiple entries)

struct WeatherForecastResponse: Decodable, Equatable {
    let Location: String
    let Forecasts: [Forecast]

    struct Forecast: Decodable, Equatable {
        let Date: String
        let High: Double
        let Low: Double
        let Condition: String
        let Precipitation: Double?
        let WindSpeed: Double?
        let Advisory: String?

        private enum CodingKeys: String, CodingKey {
            case Date, High, Low, Condition, Precipitation, WindSpeed, Advisory
        }
    }

    private enum CodingKeys: String, CodingKey {
        case Location, Forecasts
    }
}

// MARK: - Order List (multiple entries, empty arrays, nested elements)

struct OrderListResponse: Decodable, Equatable {
    let TotalCount: Int
    let Orders: [Order]

    private enum CodingKeys: String, CodingKey {
        case TotalCount, Orders
    }
}

struct Order: Decodable, Equatable {
    let OrderId: String
    let Status: String
    let Customer: OrderCustomer
    let Items: [OrderItem]
    let Notes: [String]?

    private enum CodingKeys: String, CodingKey {
        case OrderId, Status, Customer, Items, Notes
    }

    init(orderId: String, status: String, customer: OrderCustomer, items: [OrderItem], notes: [String]?) {
        self.OrderId = orderId
        self.Status = status
        self.Customer = customer
        self.Items = items
        self.Notes = notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        OrderId = try container.decode(String.self, forKey: .OrderId)
        Status = try container.decode(String.self, forKey: .Status)
        Customer = try container.decode(OrderCustomer.self, forKey: .Customer)
        Items = try container.decode([OrderItem].self, forKey: .Items)

        if container.contains(.Notes) {
            let isNil = try container.decodeNil(forKey: .Notes)
            if isNil {
                Notes = nil
            } else {
                Notes = try container.decode([String].self, forKey: .Notes)
            }
        } else {
            Notes = nil
        }
    }
}

struct OrderCustomer: Decodable, Equatable {
    let Name: String
    let Email: String?
    let Phone: String?

    private enum CodingKeys: String, CodingKey {
        case Name, Email, Phone
    }
}

struct OrderItem: Decodable, Equatable {
    let Sku: String
    let Name: String
    let Quantity: Int
    let Price: Double

    private enum CodingKeys: String, CodingKey {
        case Sku, Name, Quantity, Price
    }
}

// MARK: - Employee Directory (deeply nested, optional sections)

struct EmployeeDirectory: Decodable, Equatable {
    let Department: String
    let Employees: [Employee]

    private enum CodingKeys: String, CodingKey {
        case Department, Employees
    }
}

struct Employee: Decodable, Equatable {
    let Id: String
    let Name: String
    let Title: String
    let Contact: EmployeeContact
    let Skills: [String]?
    let Projects: [EmployeeProject]?

    private enum CodingKeys: String, CodingKey {
        case Id, Name, Title, Contact, Skills, Projects
    }

    init(id: String, name: String, title: String, contact: EmployeeContact,
         skills: [String]?, projects: [EmployeeProject]?) {
        self.Id = id
        self.Name = name
        self.Title = title
        self.Contact = contact
        self.Skills = skills
        self.Projects = projects
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        Id = try container.decode(String.self, forKey: .Id)
        Name = try container.decode(String.self, forKey: .Name)
        Title = try container.decode(String.self, forKey: .Title)
        Contact = try container.decode(EmployeeContact.self, forKey: .Contact)

        if container.contains(.Skills) {
            let isNil = try container.decodeNil(forKey: .Skills)
            Skills = isNil ? nil : try container.decode([String].self, forKey: .Skills)
        } else {
            Skills = nil
        }

        if container.contains(.Projects) {
            let isNil = try container.decodeNil(forKey: .Projects)
            Projects = isNil ? nil : try container.decode([EmployeeProject].self, forKey: .Projects)
        } else {
            Projects = nil
        }
    }
}

struct EmployeeContact: Decodable, Equatable {
    let Email: String
    let Phone: String?
    let Address: EmployeeAddress?

    private enum CodingKeys: String, CodingKey {
        case Email, Phone, Address
    }
}

struct EmployeeAddress: Decodable, Equatable {
    let Street: String
    let City: String
    let State: String
    let Zip: String

    private enum CodingKeys: String, CodingKey {
        case Street, City, State, Zip
    }
}

struct EmployeeProject: Decodable, Equatable {
    let Name: String
    let Role: String
    let Active: Bool

    private enum CodingKeys: String, CodingKey {
        case Name, Role, Active
    }
}

// MARK: - Catalog Item (SOAP payload with deeply nested structure)

struct CatalogItem: Decodable, Equatable {
    let Id: String
    let Name: String
    let Category: String
    let Pricing: CatalogPricing
    let Inventory: CatalogInventory
    let Tags: [String]?

    private enum CodingKeys: String, CodingKey {
        case Id, Name, Category, Pricing, Inventory, Tags
    }

    init(id: String, name: String, category: String, pricing: CatalogPricing,
         inventory: CatalogInventory, tags: [String]?) {
        self.Id = id
        self.Name = name
        self.Category = category
        self.Pricing = pricing
        self.Inventory = inventory
        self.Tags = tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        Id = try container.decode(String.self, forKey: .Id)
        Name = try container.decode(String.self, forKey: .Name)
        Category = try container.decode(String.self, forKey: .Category)
        Pricing = try container.decode(CatalogPricing.self, forKey: .Pricing)
        Inventory = try container.decode(CatalogInventory.self, forKey: .Inventory)

        if container.contains(.Tags) {
            let isNil = try container.decodeNil(forKey: .Tags)
            Tags = isNil ? nil : try container.decode([String].self, forKey: .Tags)
        } else {
            Tags = nil
        }
    }
}

struct CatalogPricing: Decodable, Equatable {
    let BasePrice: Double
    let Currency: String
    let Discount: Double?
    let TaxRate: Double?

    private enum CodingKeys: String, CodingKey {
        case BasePrice, Currency, Discount, TaxRate
    }
}

struct CatalogInventory: Decodable, Equatable {
    let Warehouse: String
    let Quantity: Int
    let Reserved: Int
    let ReorderThreshold: Int?

    private enum CodingKeys: String, CodingKey {
        case Warehouse, Quantity, Reserved, ReorderThreshold
    }
}

// MARK: - Notification List (Atom feed-style with unkeyed iteration)

struct NotificationFeed: Decodable {
    let notifications: [NotificationEntry]

    init(from decoder: Decoder) throws {
        var results: [NotificationEntry] = []
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            if let entry = try? container.decode(NotificationEntry.self) {
                results.append(entry)
            }
        }
        self.notifications = results
    }
}

struct NotificationEntry: Decodable, Equatable {
    let content: NotificationContent

    private enum CodingKeys: String, CodingKey {
        case content
    }
}

struct NotificationContent: Decodable, Equatable {
    let notification: NotificationPayload

    private enum CodingKeys: String, CodingKey {
        case notification = "Notification"
    }
}

struct NotificationPayload: Decodable, Equatable {
    let Id: String
    let Title: String
    let Message: String?
    let Priority: String
    let Read: Bool
    let Timestamp: String

    private enum CodingKeys: String, CodingKey {
        case Id, Title, Message, Priority, Read, Timestamp
    }
}

// MARK: - Polymorphic Metric Values

struct MetricValue: Decodable, Equatable {
    let Gauge: String?
    let Counter: String?
    let Timestamp: String?

    private enum CodingKeys: String, CodingKey {
        case Gauge, Counter, Timestamp
    }

    init(gauge: String? = nil, counter: String? = nil, timestamp: String? = nil) {
        self.Gauge = gauge
        self.Counter = counter
        self.Timestamp = timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.Gauge) {
            let isNil = try container.decodeNil(forKey: .Gauge)
            Gauge = isNil ? nil : try container.decode(String.self, forKey: .Gauge)
        } else {
            Gauge = nil
        }

        if container.contains(.Counter) {
            let isNil = try container.decodeNil(forKey: .Counter)
            Counter = isNil ? nil : try container.decode(String.self, forKey: .Counter)
        } else {
            Counter = nil
        }

        if container.contains(.Timestamp) {
            let isNil = try container.decodeNil(forKey: .Timestamp)
            Timestamp = isNil ? nil : try container.decode(String.self, forKey: .Timestamp)
        } else {
            Timestamp = nil
        }
    }
}

struct MetricItem: Decodable, Equatable {
    let Field: FieldModel
    let Value: MetricValue

    private enum CodingKeys: String, CodingKey {
        case Field, Value
    }
}

struct MetricRow: Decodable, Equatable {
    let Id: String
    let Source: String
    let Metrics: [MetricItem]

    private enum CodingKeys: String, CodingKey {
        case Id, Source, Metrics
    }
}
