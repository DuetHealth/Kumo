import Foundation
import XCTest
@testable import Kumo
@testable import KumoCoding

// All XML fixtures in this file are synthetic test data.
// Domains (weather, e-commerce, employee directory, metrics) are fictional
// and used solely to exercise KumoCoding's XMLDecoder against a broad
// range of structural patterns found in real-world XML APIs.

class GenericXMLDecodingTests: XCTestCase {

    // MARK: - Multiple Entries

    /// Decodes a response containing multiple forecast entries,
    /// verifying that repeated sibling elements decode as an array.
    func testDecodeMultipleForecasts() {
        let decoder = XMLDecoder()
        let data = """
        <WeatherForecastResponse>
            <Location>Springfield</Location>
            <Forecasts>
                <Forecast>
                    <Date>2025-04-07</Date>
                    <High>72.5</High>
                    <Low>54.0</Low>
                    <Condition>Sunny</Condition>
                    <Precipitation>0.0</Precipitation>
                    <WindSpeed>12.3</WindSpeed>
                    <Advisory>UV Index High</Advisory>
                </Forecast>
                <Forecast>
                    <Date>2025-04-08</Date>
                    <High>65.0</High>
                    <Low>48.5</Low>
                    <Condition>Cloudy</Condition>
                    <Precipitation>0.25</Precipitation>
                </Forecast>
                <Forecast>
                    <Date>2025-04-09</Date>
                    <High>58.0</High>
                    <Low>42.0</Low>
                    <Condition>Rain</Condition>
                    <Precipitation>1.5</Precipitation>
                    <WindSpeed>25.0</WindSpeed>
                </Forecast>
            </Forecasts>
        </WeatherForecastResponse>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(WeatherForecastResponse.self, from: data)
            XCTAssertEqual(response.Location, "Springfield")
            XCTAssertEqual(response.Forecasts.count, 3)
            XCTAssertEqual(response.Forecasts[0].Date, "2025-04-07")
            XCTAssertEqual(response.Forecasts[0].High, 72.5)
            XCTAssertEqual(response.Forecasts[0].Condition, "Sunny")
            XCTAssertEqual(response.Forecasts[0].Advisory, "UV Index High")
            XCTAssertEqual(response.Forecasts[1].Date, "2025-04-08")
            XCTAssertNil(response.Forecasts[1].WindSpeed)
            XCTAssertNil(response.Forecasts[1].Advisory)
            XCTAssertEqual(response.Forecasts[2].Precipitation, 1.5)
            XCTAssertEqual(response.Forecasts[2].WindSpeed, 25.0)
            XCTAssertNil(response.Forecasts[2].Advisory)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Missing Optional Fields

    /// Decodes a forecast where all optional fields are absent.
    func testDecodeForecastWithAllOptionalsAbsent() {
        let decoder = XMLDecoder()
        let data = """
        <WeatherForecastResponse>
            <Location>Shelbyville</Location>
            <Forecasts>
                <Forecast>
                    <Date>2025-04-07</Date>
                    <High>60.0</High>
                    <Low>45.0</Low>
                    <Condition>Overcast</Condition>
                </Forecast>
            </Forecasts>
        </WeatherForecastResponse>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(WeatherForecastResponse.self, from: data)
            XCTAssertEqual(response.Forecasts.count, 1)
            let forecast = response.Forecasts[0]
            XCTAssertEqual(forecast.Condition, "Overcast")
            XCTAssertNil(forecast.Precipitation)
            XCTAssertNil(forecast.WindSpeed)
            XCTAssertNil(forecast.Advisory)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    /// Decodes a forecast where optional fields are present but self-closing (empty).
    func testDecodeForecastWithSelfClosingOptionals() {
        let decoder = XMLDecoder()
        let data = """
        <WeatherForecastResponse>
            <Location>Capital City</Location>
            <Forecasts>
                <Forecast>
                    <Date>2025-04-10</Date>
                    <High>55.0</High>
                    <Low>40.0</Low>
                    <Condition>Clear</Condition>
                    <Precipitation />
                    <WindSpeed />
                    <Advisory />
                </Forecast>
            </Forecasts>
        </WeatherForecastResponse>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(WeatherForecastResponse.self, from: data)
            let forecast = response.Forecasts[0]
            XCTAssertEqual(forecast.Date, "2025-04-10")
            XCTAssertNil(forecast.Precipitation)
            XCTAssertNil(forecast.WindSpeed)
            XCTAssertNil(forecast.Advisory)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Empty Arrays

    /// Decodes an order where the notes array is a self-closing empty tag.
    func testDecodeOrderWithEmptyNotes() {
        let decoder = XMLDecoder()
        let data = """
        <OrderListResponse>
            <TotalCount>1</TotalCount>
            <Orders>
                <Order>
                    <OrderId>ORD-1001</OrderId>
                    <Status>Shipped</Status>
                    <Customer>
                        <Name>Alice Johnson</Name>
                        <Email>alice@example.com</Email>
                    </Customer>
                    <Items>
                        <OrderItem>
                            <Sku>WIDGET-42</Sku>
                            <Name>Blue Widget</Name>
                            <Quantity>3</Quantity>
                            <Price>9.99</Price>
                        </OrderItem>
                    </Items>
                    <Notes />
                </Order>
            </Orders>
        </OrderListResponse>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(OrderListResponse.self, from: data)
            XCTAssertEqual(response.TotalCount, 1)
            XCTAssertEqual(response.Orders.count, 1)
            XCTAssertEqual(response.Orders[0].OrderId, "ORD-1001")
            XCTAssertNil(response.Orders[0].Notes)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    /// Decodes an order where the notes array is completely absent.
    func testDecodeOrderWithAbsentNotes() {
        let decoder = XMLDecoder()
        let data = """
        <OrderListResponse>
            <TotalCount>1</TotalCount>
            <Orders>
                <Order>
                    <OrderId>ORD-1002</OrderId>
                    <Status>Processing</Status>
                    <Customer>
                        <Name>Bob Smith</Name>
                    </Customer>
                    <Items>
                        <OrderItem>
                            <Sku>GADGET-99</Sku>
                            <Name>Red Gadget</Name>
                            <Quantity>1</Quantity>
                            <Price>24.50</Price>
                        </OrderItem>
                    </Items>
                </Order>
            </Orders>
        </OrderListResponse>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(OrderListResponse.self, from: data)
            XCTAssertEqual(response.Orders[0].OrderId, "ORD-1002")
            XCTAssertNil(response.Orders[0].Customer.Email)
            XCTAssertNil(response.Orders[0].Customer.Phone)
            XCTAssertNil(response.Orders[0].Notes)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Multiple Entries with Varying Completeness

    /// Decodes multiple orders where some have notes and others don't,
    /// testing heterogeneous content within the same array.
    func testDecodeMultipleOrdersWithVaryingCompleteness() {
        let decoder = XMLDecoder()
        let data = """
        <OrderListResponse>
            <TotalCount>3</TotalCount>
            <Orders>
                <Order>
                    <OrderId>ORD-2001</OrderId>
                    <Status>Delivered</Status>
                    <Customer>
                        <Name>Charlie Brown</Name>
                        <Email>charlie@example.com</Email>
                        <Phone>555-0101</Phone>
                    </Customer>
                    <Items>
                        <OrderItem>
                            <Sku>BOOK-A1</Sku>
                            <Name>Adventure Novel</Name>
                            <Quantity>2</Quantity>
                            <Price>14.99</Price>
                        </OrderItem>
                        <OrderItem>
                            <Sku>BOOK-B2</Sku>
                            <Name>Mystery Collection</Name>
                            <Quantity>1</Quantity>
                            <Price>22.50</Price>
                        </OrderItem>
                    </Items>
                    <Notes>
                        <Note>Gift wrap requested</Note>
                        <Note>Leave at door</Note>
                    </Notes>
                </Order>
                <Order>
                    <OrderId>ORD-2002</OrderId>
                    <Status>Cancelled</Status>
                    <Customer>
                        <Name>Diana Prince</Name>
                    </Customer>
                    <Items>
                        <OrderItem>
                            <Sku>TOY-X7</Sku>
                            <Name>Action Figure</Name>
                            <Quantity>1</Quantity>
                            <Price>19.99</Price>
                        </OrderItem>
                    </Items>
                </Order>
                <Order>
                    <OrderId>ORD-2003</OrderId>
                    <Status>Processing</Status>
                    <Customer>
                        <Name>Eve Torres</Name>
                        <Email>eve@example.com</Email>
                    </Customer>
                    <Items>
                        <OrderItem>
                            <Sku>ELEC-Z3</Sku>
                            <Name>Wireless Headphones</Name>
                            <Quantity>1</Quantity>
                            <Price>79.99</Price>
                        </OrderItem>
                    </Items>
                    <Notes />
                </Order>
            </Orders>
        </OrderListResponse>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(OrderListResponse.self, from: data)
            XCTAssertEqual(response.TotalCount, 3)
            XCTAssertEqual(response.Orders.count, 3)

            // Order 1: fully populated with notes
            XCTAssertEqual(response.Orders[0].OrderId, "ORD-2001")
            XCTAssertEqual(response.Orders[0].Customer.Phone, "555-0101")
            XCTAssertEqual(response.Orders[0].Items.count, 2)
            XCTAssertEqual(response.Orders[0].Items[1].Sku, "BOOK-B2")
            XCTAssertEqual(response.Orders[0].Notes, ["Gift wrap requested", "Leave at door"])

            // Order 2: minimal — no email, no phone, no notes
            XCTAssertEqual(response.Orders[1].OrderId, "ORD-2002")
            XCTAssertNil(response.Orders[1].Customer.Email)
            XCTAssertNil(response.Orders[1].Customer.Phone)
            XCTAssertNil(response.Orders[1].Notes)

            // Order 3: empty self-closing notes
            XCTAssertEqual(response.Orders[2].OrderId, "ORD-2003")
            XCTAssertNil(response.Orders[2].Notes)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Deeply Nested Elements

    /// Decodes an employee directory with deeply nested address information
    /// and optional skill/project arrays.
    func testDecodeEmployeeDirectoryWithDeepNesting() {
        let decoder = XMLDecoder()
        let data = """
        <EmployeeDirectory>
            <Department>Engineering</Department>
            <Employees>
                <Employee>
                    <Id>EMP-001</Id>
                    <Name>Grace Hopper</Name>
                    <Title>Principal Engineer</Title>
                    <Contact>
                        <Email>grace@example.com</Email>
                        <Phone>555-0199</Phone>
                        <Address>
                            <Street>123 Oak Avenue</Street>
                            <City>Metropolis</City>
                            <State>NY</State>
                            <Zip>10001</Zip>
                        </Address>
                    </Contact>
                    <Skills>
                        <Skill>Swift</Skill>
                        <Skill>Objective-C</Skill>
                        <Skill>Python</Skill>
                    </Skills>
                    <Projects>
                        <Project>
                            <Name>Atlas</Name>
                            <Role>Lead</Role>
                            <Active>true</Active>
                        </Project>
                        <Project>
                            <Name>Beacon</Name>
                            <Role>Contributor</Role>
                            <Active>false</Active>
                        </Project>
                    </Projects>
                </Employee>
            </Employees>
        </EmployeeDirectory>
        """.data(using: .utf8)!

        do {
            let directory = try decoder.decode(EmployeeDirectory.self, from: data)
            XCTAssertEqual(directory.Department, "Engineering")
            XCTAssertEqual(directory.Employees.count, 1)

            let emp = directory.Employees[0]
            XCTAssertEqual(emp.Id, "EMP-001")
            XCTAssertEqual(emp.Name, "Grace Hopper")

            // Deeply nested address
            XCTAssertEqual(emp.Contact.Address?.Street, "123 Oak Avenue")
            XCTAssertEqual(emp.Contact.Address?.City, "Metropolis")
            XCTAssertEqual(emp.Contact.Address?.State, "NY")
            XCTAssertEqual(emp.Contact.Address?.Zip, "10001")

            // Skills array
            XCTAssertEqual(emp.Skills, ["Swift", "Objective-C", "Python"])

            // Projects with nested boolean
            XCTAssertEqual(emp.Projects?.count, 2)
            XCTAssertEqual(emp.Projects?[0].Name, "Atlas")
            XCTAssertEqual(emp.Projects?[0].Active, true)
            XCTAssertEqual(emp.Projects?[1].Active, false)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    /// Decodes an employee with no address, no skills, and no projects.
    func testDecodeEmployeeWithMinimalData() {
        let decoder = XMLDecoder()
        let data = """
        <EmployeeDirectory>
            <Department>Marketing</Department>
            <Employees>
                <Employee>
                    <Id>EMP-002</Id>
                    <Name>Alan Turing</Name>
                    <Title>Analyst</Title>
                    <Contact>
                        <Email>alan@example.com</Email>
                    </Contact>
                </Employee>
            </Employees>
        </EmployeeDirectory>
        """.data(using: .utf8)!

        do {
            let directory = try decoder.decode(EmployeeDirectory.self, from: data)
            let emp = directory.Employees[0]
            XCTAssertEqual(emp.Id, "EMP-002")
            XCTAssertEqual(emp.Contact.Email, "alan@example.com")
            XCTAssertNil(emp.Contact.Phone)
            XCTAssertNil(emp.Contact.Address)
            XCTAssertNil(emp.Skills)
            XCTAssertNil(emp.Projects)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    /// Decodes an employee with empty self-closing skills and projects.
    func testDecodeEmployeeWithEmptySelfClosingArrays() {
        let decoder = XMLDecoder()
        let data = """
        <EmployeeDirectory>
            <Department>Design</Department>
            <Employees>
                <Employee>
                    <Id>EMP-003</Id>
                    <Name>Ada Lovelace</Name>
                    <Title>Designer</Title>
                    <Contact>
                        <Email>ada@example.com</Email>
                        <Phone />
                    </Contact>
                    <Skills />
                    <Projects />
                </Employee>
            </Employees>
        </EmployeeDirectory>
        """.data(using: .utf8)!

        do {
            let directory = try decoder.decode(EmployeeDirectory.self, from: data)
            let emp = directory.Employees[0]
            XCTAssertEqual(emp.Id, "EMP-003")
            XCTAssertNil(emp.Contact.Phone)
            XCTAssertNil(emp.Skills)
            XCTAssertNil(emp.Projects)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Multiple Employees (varied completeness)

    /// Decodes a directory with multiple employees at different levels
    /// of data completeness, testing heterogeneous sibling elements.
    func testDecodeMultipleEmployeesWithVaryingCompleteness() {
        let decoder = XMLDecoder()
        let data = """
        <EmployeeDirectory>
            <Department>Research</Department>
            <Employees>
                <Employee>
                    <Id>EMP-101</Id>
                    <Name>Marie Curie</Name>
                    <Title>Research Scientist</Title>
                    <Contact>
                        <Email>marie@example.com</Email>
                        <Phone>555-0201</Phone>
                        <Address>
                            <Street>456 Elm Street</Street>
                            <City>Gotham</City>
                            <State>NJ</State>
                            <Zip>07001</Zip>
                        </Address>
                    </Contact>
                    <Skills>
                        <Skill>Chemistry</Skill>
                        <Skill>Physics</Skill>
                    </Skills>
                    <Projects>
                        <Project>
                            <Name>Radiance</Name>
                            <Role>Principal Investigator</Role>
                            <Active>true</Active>
                        </Project>
                    </Projects>
                </Employee>
                <Employee>
                    <Id>EMP-102</Id>
                    <Name>Nikola Tesla</Name>
                    <Title>Staff Engineer</Title>
                    <Contact>
                        <Email>nikola@example.com</Email>
                    </Contact>
                </Employee>
                <Employee>
                    <Id>EMP-103</Id>
                    <Name>Rosalind Franklin</Name>
                    <Title>Senior Scientist</Title>
                    <Contact>
                        <Email>rosalind@example.com</Email>
                        <Phone>555-0203</Phone>
                    </Contact>
                    <Skills />
                    <Projects />
                </Employee>
            </Employees>
        </EmployeeDirectory>
        """.data(using: .utf8)!

        do {
            let directory = try decoder.decode(EmployeeDirectory.self, from: data)
            XCTAssertEqual(directory.Department, "Research")
            XCTAssertEqual(directory.Employees.count, 3)

            // Fully populated employee
            XCTAssertEqual(directory.Employees[0].Skills, ["Chemistry", "Physics"])
            XCTAssertEqual(directory.Employees[0].Projects?.count, 1)
            XCTAssertEqual(directory.Employees[0].Contact.Address?.City, "Gotham")

            // Minimal employee — no phone, no address, no skills, no projects
            XCTAssertNil(directory.Employees[1].Contact.Phone)
            XCTAssertNil(directory.Employees[1].Contact.Address)
            XCTAssertNil(directory.Employees[1].Skills)
            XCTAssertNil(directory.Employees[1].Projects)

            // Employee with empty arrays (self-closing tags)
            XCTAssertEqual(directory.Employees[2].Contact.Phone, "555-0203")
            XCTAssertNil(directory.Employees[2].Skills)
            XCTAssertNil(directory.Employees[2].Projects)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - SOAP Envelope with Nested Catalog Item

    /// Decodes a deeply nested SOAP response for a catalog item.
    func testDecodeSOAPCatalogItem() {
        let decoder = SOAPDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let data = """
        <?xml version="1.0"?>
        <soap:Envelope
        xmlns:soap="http://www.w3.org/2003/05/soap-envelope/"
        soap:encodingStyle="http://www.w3.org/2003/05/soap-encoding">
            <soap:Body>
                <m:CatalogItem xmlns:m="https://www.example.com/catalog">
                    <m:Id>CAT-5001</m:Id>
                    <m:Name>Ergonomic Keyboard</m:Name>
                    <m:Category>Electronics</m:Category>
                    <m:Pricing>
                        <m:BasePrice>89.99</m:BasePrice>
                        <m:Currency>USD</m:Currency>
                        <m:Discount>0.15</m:Discount>
                        <m:TaxRate>0.08</m:TaxRate>
                    </m:Pricing>
                    <m:Inventory>
                        <m:Warehouse>Central</m:Warehouse>
                        <m:Quantity>150</m:Quantity>
                        <m:Reserved>12</m:Reserved>
                        <m:ReorderThreshold>25</m:ReorderThreshold>
                    </m:Inventory>
                    <m:Tags>
                        <m:Tag>keyboard</m:Tag>
                        <m:Tag>ergonomic</m:Tag>
                        <m:Tag>office</m:Tag>
                    </m:Tags>
                </m:CatalogItem>
            </soap:Body>
        </soap:Envelope>
        """.data(using: .utf8)!

        do {
            let item: CatalogItem = try decoder.decode(from: data)
            XCTAssertEqual(item.Id, "CAT-5001")
            XCTAssertEqual(item.Name, "Ergonomic Keyboard")
            XCTAssertEqual(item.Category, "Electronics")
            XCTAssertEqual(item.Pricing.BasePrice, 89.99)
            XCTAssertEqual(item.Pricing.Currency, "USD")
            XCTAssertEqual(item.Pricing.Discount, 0.15)
            XCTAssertEqual(item.Pricing.TaxRate, 0.08)
            XCTAssertEqual(item.Inventory.Warehouse, "Central")
            XCTAssertEqual(item.Inventory.Quantity, 150)
            XCTAssertEqual(item.Inventory.Reserved, 12)
            XCTAssertEqual(item.Inventory.ReorderThreshold, 25)
            XCTAssertEqual(item.Tags, ["keyboard", "ergonomic", "office"])
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    /// Decodes a SOAP catalog item where optional pricing/inventory
    /// fields and the tags array are absent.
    func testDecodeSOAPCatalogItemWithOptionalsMissing() {
        let decoder = SOAPDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let data = """
        <?xml version="1.0"?>
        <soap:Envelope
        xmlns:soap="http://www.w3.org/2003/05/soap-envelope/"
        soap:encodingStyle="http://www.w3.org/2003/05/soap-encoding">
            <soap:Body>
                <m:CatalogItem xmlns:m="https://www.example.com/catalog">
                    <m:Id>CAT-5002</m:Id>
                    <m:Name>Basic Mouse</m:Name>
                    <m:Category>Accessories</m:Category>
                    <m:Pricing>
                        <m:BasePrice>12.99</m:BasePrice>
                        <m:Currency>EUR</m:Currency>
                    </m:Pricing>
                    <m:Inventory>
                        <m:Warehouse>East</m:Warehouse>
                        <m:Quantity>500</m:Quantity>
                        <m:Reserved>0</m:Reserved>
                    </m:Inventory>
                </m:CatalogItem>
            </soap:Body>
        </soap:Envelope>
        """.data(using: .utf8)!

        do {
            let item: CatalogItem = try decoder.decode(from: data)
            XCTAssertEqual(item.Id, "CAT-5002")
            XCTAssertEqual(item.Pricing.BasePrice, 12.99)
            XCTAssertNil(item.Pricing.Discount)
            XCTAssertNil(item.Pricing.TaxRate)
            XCTAssertNil(item.Inventory.ReorderThreshold)
            XCTAssertNil(item.Tags)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    /// Decodes a SOAP catalog item where the tags array is empty (self-closing).
    func testDecodeSOAPCatalogItemWithEmptyTags() {
        let decoder = SOAPDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let data = """
        <?xml version="1.0"?>
        <soap:Envelope
        xmlns:soap="http://www.w3.org/2003/05/soap-envelope/"
        soap:encodingStyle="http://www.w3.org/2003/05/soap-encoding">
            <soap:Body>
                <m:CatalogItem xmlns:m="https://www.example.com/catalog">
                    <m:Id>CAT-5003</m:Id>
                    <m:Name>Notebook Stand</m:Name>
                    <m:Category>Furniture</m:Category>
                    <m:Pricing>
                        <m:BasePrice>45.00</m:BasePrice>
                        <m:Currency>USD</m:Currency>
                    </m:Pricing>
                    <m:Inventory>
                        <m:Warehouse>West</m:Warehouse>
                        <m:Quantity>30</m:Quantity>
                        <m:Reserved>5</m:Reserved>
                    </m:Inventory>
                    <m:Tags />
                </m:CatalogItem>
            </soap:Body>
        </soap:Envelope>
        """.data(using: .utf8)!

        do {
            let item: CatalogItem = try decoder.decode(from: data)
            XCTAssertEqual(item.Id, "CAT-5003")
            XCTAssertNil(item.Tags)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Atom Feed–Style with Unkeyed Iteration

    /// Decodes an Atom-style feed containing notification entries,
    /// verifying the unkeyed container iteration pattern.
    func testDecodeNotificationFeed() {
        let decoder = XMLDecoder()
        let data = """
        <feed xmlns="http://www.w3.org/2005/Atom">
            <id>http://example.com/notifications</id>
            <title>Notifications</title>
            <updated>2025-04-07T12:00:00Z</updated>
            <author><name>System</name></author>
            <entry>
                <id>http://example.com/notification/1</id>
                <title>Notification</title>
                <updated>2025-04-07T12:00:00Z</updated>
                <author><name>System</name></author>
                <content>
                    <Notification>
                        <Id>N-001</Id>
                        <Title>Deployment Complete</Title>
                        <Message>Version 2.5.0 deployed successfully.</Message>
                        <Priority>High</Priority>
                        <Read>false</Read>
                        <Timestamp>2025-04-07T11:30:00Z</Timestamp>
                    </Notification>
                </content>
            </entry>
            <entry>
                <id>http://example.com/notification/2</id>
                <title>Notification</title>
                <updated>2025-04-07T12:00:00Z</updated>
                <author><name>System</name></author>
                <content>
                    <Notification>
                        <Id>N-002</Id>
                        <Title>Scheduled Maintenance</Title>
                        <Priority>Low</Priority>
                        <Read>true</Read>
                        <Timestamp>2025-04-06T09:00:00Z</Timestamp>
                    </Notification>
                </content>
            </entry>
            <entry>
                <id>http://example.com/notification/3</id>
                <title>Notification</title>
                <updated>2025-04-07T12:00:00Z</updated>
                <author><name>System</name></author>
                <content>
                    <Notification>
                        <Id>N-003</Id>
                        <Title>New User Registered</Title>
                        <Message>User john@example.com registered.</Message>
                        <Priority>Medium</Priority>
                        <Read>false</Read>
                        <Timestamp>2025-04-07T08:15:00Z</Timestamp>
                    </Notification>
                </content>
            </entry>
        </feed>
        """.data(using: .utf8)!

        do {
            let feed = try decoder.decode(NotificationFeed.self, from: data)
            XCTAssertEqual(feed.notifications.count, 3)

            // Entry 1: has message
            let n1 = feed.notifications[0].content.notification
            XCTAssertEqual(n1.Id, "N-001")
            XCTAssertEqual(n1.Title, "Deployment Complete")
            XCTAssertEqual(n1.Message, "Version 2.5.0 deployed successfully.")
            XCTAssertEqual(n1.Priority, "High")
            XCTAssertEqual(n1.Read, false)

            // Entry 2: missing message
            let n2 = feed.notifications[1].content.notification
            XCTAssertEqual(n2.Id, "N-002")
            XCTAssertNil(n2.Message)
            XCTAssertEqual(n2.Read, true)

            // Entry 3: has message
            let n3 = feed.notifications[2].content.notification
            XCTAssertEqual(n3.Id, "N-003")
            XCTAssertEqual(n3.Message, "User john@example.com registered.")
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Polymorphic Metric Values

    /// Decodes metric rows with polymorphic value types (Gauge, Counter, Timestamp),
    /// verifying that only the populated sub-element is non-nil.
    func testDecodeMetricRowWithPolymorphicValues() {
        let decoder = XMLDecoder()
        let data = """
        <MetricRow xmlns="http://test.example.com/Model/Metrics">
            <Id>http://example.com/metrics/cpu-usage</Id>
            <Source>Server</Source>
            <Metrics>
                <MetricItem>
                    <Field><Source>Server</Source><Attribute>CPUUsage</Attribute></Field>
                    <Value><Gauge>87.5</Gauge></Value>
                </MetricItem>
                <MetricItem>
                    <Field><Source>Server</Source><Attribute>RequestCount</Attribute></Field>
                    <Value><Counter>14523</Counter></Value>
                </MetricItem>
                <MetricItem>
                    <Field><Source>Server</Source><Attribute>LastRestart</Attribute></Field>
                    <Value><Timestamp>2025-04-01T06:00:00Z</Timestamp></Value>
                </MetricItem>
                <MetricItem>
                    <Field><Source>Server</Source><Attribute>ErrorRate</Attribute></Field>
                    <Value><Gauge /></Value>
                </MetricItem>
            </Metrics>
        </MetricRow>
        """.data(using: .utf8)!

        do {
            let row = try decoder.decode(MetricRow.self, from: data)
            XCTAssertEqual(row.Id, "http://example.com/metrics/cpu-usage")
            XCTAssertEqual(row.Source, "Server")
            XCTAssertEqual(row.Metrics.count, 4)

            // Gauge value
            XCTAssertEqual(row.Metrics[0].Value.Gauge, "87.5")
            XCTAssertNil(row.Metrics[0].Value.Counter)
            XCTAssertNil(row.Metrics[0].Value.Timestamp)

            // Counter value
            XCTAssertNil(row.Metrics[1].Value.Gauge)
            XCTAssertEqual(row.Metrics[1].Value.Counter, "14523")

            // Timestamp value
            XCTAssertEqual(row.Metrics[2].Value.Timestamp, "2025-04-01T06:00:00Z")
            XCTAssertNil(row.Metrics[2].Value.Gauge)

            // Empty Gauge (self-closing)
            XCTAssertNil(row.Metrics[3].Value.Gauge)
            XCTAssertNil(row.Metrics[3].Value.Counter)
            XCTAssertNil(row.Metrics[3].Value.Timestamp)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Single Item Array

    /// Verifies that an array containing exactly one element decodes correctly.
    func testDecodeSingleItemList() {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let data = """
        <ListContainer>
            <SimpleList>
                <Element>only-one</Element>
            </SimpleList>
        </ListContainer>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(ListContainer.self, from: data)
            XCTAssertEqual(response.simpleList, ["only-one"])
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Numeric Edge Cases

    /// Decodes various numeric representations (zero, negative, large values).
    func testDecodeNumericEdgeCases() {
        let decoder = XMLDecoder()

        // Zero
        let zeroData = """
        <DefaultKeyModel>
            <title>Numbers</title>
            <count>0</count>
        </DefaultKeyModel>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(DefaultKeyModel.self, from: zeroData)
            XCTAssertEqual(response.count, 0)
        } catch {
            XCTFail("Decode failed: \(error)")
        }

        // Negative
        let negativeData = """
        <DefaultKeyModel>
            <title>Negative</title>
            <count>-42</count>
        </DefaultKeyModel>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(DefaultKeyModel.self, from: negativeData)
            XCTAssertEqual(response.count, -42)
        } catch {
            XCTFail("Decode failed: \(error)")
        }

        // Int max
        let largeData = """
        <DefaultKeyModel>
            <title>Large</title>
            <count>2147483647</count>
        </DefaultKeyModel>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(DefaultKeyModel.self, from: largeData)
            XCTAssertEqual(response.count, 2147483647)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Whitespace-Only Content Treated as Empty

    /// Verifies that elements containing only whitespace are treated as empty nodes.
    func testDecodeWhitespaceOnlyContentAsEmpty() {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let data = """
        <NilableContainer>
            <Name>WhitespaceTest</Name>
            <Nickname>   </Nickname>
        </NilableContainer>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(NilableContainer.self, from: data)
            XCTAssertEqual(response.name, "WhitespaceTest")
            // The XMLDeserializer trims whitespace content, so whitespace-only
            // becomes an empty node which decodes as nil.
            XCTAssertNil(response.nickname)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Namespace Stripping

    /// Verifies that elements with namespace prefixes decode correctly
    /// since XMLParser with shouldProcessNamespaces strips prefixes.
    func testDecodeNamespacedElements() {
        let decoder = XMLDecoder()
        let data = """
        <Root xmlns:ns="http://example.com/test">
            <ns:title>Namespaced</ns:title>
            <ns:count>7</ns:count>
        </Root>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(DefaultKeyModel.self, from: data)
            XCTAssertEqual(response.title, "Namespaced")
            XCTAssertEqual(response.count, 7)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Complex List with Single Element

    /// Verifies that a complex object list with a single element decodes correctly.
    func testDecodeComplexListWithSingleElement() {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let data = """
        <ComplexListContainer>
            <ComplexList>
                <ComplexElement>
                    <X>alpha</X>
                    <Y>beta</Y>
                </ComplexElement>
            </ComplexList>
        </ComplexListContainer>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(ComplexListContainer.self, from: data)
            XCTAssertEqual(response.complexList.count, 1)
            XCTAssertEqual(response.complexList[0].x, "alpha")
            XCTAssertEqual(response.complexList[0].y, "beta")
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - SOAP Round-Trip with Catalog Payload

    /// Encodes then decodes a price response through SOAP to verify round-trip integrity.
    func testSOAPCatalogItemRoundTrip() {
        let original = GetPriceResponse(
            price: GetPriceResponse.Price(amount: 42.0, units: "GBP"),
            discount: 0.10
        )

        let encoder = SOAPEncoder()
        encoder.keyEncodingStrategy = .convertToPascalCase
        encoder.soapNamespaceUsage = .define(
            using: XMLNamespace(prefix: "soap", uri: "http://www.w3.org/2003/05/soap-envelope/"),
            including: []
        )
        encoder.requestPayloadNamespaceUsage = .defineBeneath(
            XMLNamespace(prefix: "m", uri: "https://www.example.com/prices")
        )

        let decoder = SOAPDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase

        do {
            let data = try encoder.encode(original)
            let decoded: GetPriceResponse = try decoder.decode(from: data)
            XCTAssertEqual(decoded, original)
        } catch {
            XCTFail("Round-trip failed: \(error)")
        }
    }

    // MARK: - Error: Missing Required Key in Nested Object

    /// Verifies that a missing required key in a nested object throws keyNotFound.
    func testDecodingMissingRequiredKeyInNestedObjectThrows() {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let data = """
        <EmployeeDirectory>
            <Department>QA</Department>
            <Employees>
                <Employee>
                    <Id>EMP-BAD</Id>
                    <Name>Missing Title</Name>
                    <Contact>
                        <Email>bad@example.com</Email>
                    </Contact>
                </Employee>
            </Employees>
        </EmployeeDirectory>
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(EmployeeDirectory.self, from: data)) { error in
            guard case DecodingError.keyNotFound = error else {
                XCTFail("Expected DecodingError.keyNotFound but got \(error)")
                return
            }
        }
    }

    // MARK: - Large Array Decode

    /// Decodes a string list with many elements to verify the unkeyed
    /// container handles larger counts correctly.
    func testDecodeLargeStringList() {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let elements = (1...50).map { "<Element>item-\($0)</Element>" }.joined(separator: "\n")
        let data = """
        <ListContainer>
            <SimpleList>
                \(elements)
            </SimpleList>
        </ListContainer>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(ListContainer.self, from: data)
            XCTAssertEqual(response.simpleList.count, 50)
            XCTAssertEqual(response.simpleList.first, "item-1")
            XCTAssertEqual(response.simpleList.last, "item-50")
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }

    // MARK: - Decode with Multiple Namespaces

    /// Verifies decode still works when multiple namespace declarations exist
    /// on the same element, since XMLParser strips prefixes.
    func testDecodeWithMultipleNamespaceDeclarations() {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let data = """
        <NilableContainer xmlns="http://example.com/primary" xmlns:sec="http://example.com/secondary">
            <Name>MultiNS</Name>
        </NilableContainer>
        """.data(using: .utf8)!

        do {
            let response = try decoder.decode(NilableContainer.self, from: data)
            XCTAssertEqual(response.name, "MultiNS")
            XCTAssertNil(response.nickname)
        } catch {
            XCTFail("Decode failed: \(error)")
        }
    }
}
