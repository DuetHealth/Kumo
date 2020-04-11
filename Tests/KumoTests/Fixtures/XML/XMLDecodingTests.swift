import Foundation
import XCTest
@testable import Kumo
@testable import KumoCoding

class XMLDecodingTests: XCTestCase {

    func testDecodingSimpleSOAPRequest() {
        let decoder = SOAPDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let data = """
        <?xml version="1.0"?>
        <soap:Envelope
        xmlns:soap="http://www.w3.org/2003/05/soap-envelope/"
        soap:encodingStyle="http://www.w3.org/2003/05/soap-encoding">
            <soap:Body>
                <m:GetPriceResponse xmlns:m="https://www.w3schools.com/prices">
                    <m:Price>
                        <m:Amount>1.90</m:Amount>
                        <m:Units>Dollars</m:Units>
                    </m:Price>
                    <m:Discount>0.15</m:Discount>
                </m:GetPriceResponse>
            </soap:Body>
        </soap:Envelope>
        """.data(using: .utf8)!
        do {
            let response: GetPriceResponse = try decoder.decode(from: data)
            let expected = GetPriceResponse(price: GetPriceResponse.Price(amount: 1.9, units: "Dollars"), discount: 0.15)
            XCTAssertTrue(response == expected)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testDecodingEpicAuthenticationRequest() {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let data = """
        <Authenticate xmlns="urn:Epic-com:MyChartMobile.2010.Services">
            <Username>Username</Username>
            <Password>Password</Password>
            <DeviceID>E31A21DE-1167-45D3-8845-FD5F65AA5E4C</DeviceID>
            <AppID>com.advocate.myadvocate.tst-iPhone</AppID>
        </Authenticate>
        """.data(using: .utf8)!
        do {
            let response: Authenticate = try decoder.decode(Authenticate.self, from: data)
            let expected = Authenticate(username: "Username", password: "Password", deviceID: "E31A21DE-1167-45D3-8845-FD5F65AA5E4C", appID: "com.advocate.myadvocate.tst-iPhone")
            XCTAssertTrue(response == expected)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testDecodingEpicAuthenticateResponse() {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let data = """
        <AuthenticateResponse xmlns="urn:Epic-com:MyChartMobile.2010.Services" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"> <AccountID>1394190</AccountID> <AllowTrustedDevices>false</AllowTrustedDevices> <AllowedHosts xmlns:a="http://schemas.microsoft.com/2003/10/Serialization/Arrays"></AllowedHosts> <AllowedServiceAreas xmlns:a="http://schemas.microsoft.com/2003/10/Serialization/Arrays"></AllowedServiceAreas> <Available2011Features>1</Available2011Features> <Available2012Features>1</Available2012Features> <Available2013Features>1</Available2013Features> <Available2014Features>63</Available2014Features> <Available2015Features>15</Available2015Features> <Available2016Features>2047</Available2016Features> <Available2017Features>1047550</Available2017Features> <Available2018Features>67098623</Available2018Features> <Available2019Features>1</Available2019Features> <CommunityConsentStatus>1</CommunityConsentStatus> <DeviceTimeout>10</DeviceTimeout> <DisplayName>Joyce (Mom)</DisplayName> <FeatureInformation> <AllowRxRefill>true</AllowRxRefill> <DisabledFeatures xmlns:a="http://schemas.microsoft.com/2003/10/Serialization/Arrays"></DisabledFeatures> <EnabledFeatures xmlns:a="http://schemas.microsoft.com/2003/10/Serialization/Arrays"> <a:string>ACCOUNTDETAILS</a:string><a:string>ACCOUNTDETAILS2</a:string></EnabledFeatures> </FeatureInformation> <HomeURL i:nil="true"></HomeURL> <IsAdmitted>false</IsAdmitted> <IsFinlandEnv>false</IsFinlandEnv> <IsInED>false</IsInED> <IsPatient>true</IsPatient> <LegalName>Joyce Mychart</LegalName> <Method>2</Method> <Name>Joyce Mychart</Name> <NowContextID></NowContextID> <Photo>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</Photo> <ReadOnlyServer>false</ReadOnlyServer> <ShowNonProductionWarning>true</ShowNonProductionWarning> <ShowTerms>DoNotShow</ShowTerms> <SsoUsernameForCache></SsoUsernameForCache> <Status>Success</Status> <TermsConditions></TermsConditions> <Ticket>1FAB0BF1D7EAC11C82669B33EC8AB2F86F43B76E327B68A036B6AD026ED21F80684E74115B8BC5F112AC1285CF45D39932DF71E6060E3E4EF0AC3BCB3F4E1BB24086C9F5D7F076A0F322E39B66289F74ACD043E18928EEE7D52B5708A2D2FE36DF28235FD8469F3B8AE3547C3F09B49C8B70CC71F7AB6E8693C7AB00D9196BFA7A0D90BE98A7E474F04C3DAE95BB1A81DE001F49EA5463E7C6FB0EAA612ED28DB24F679D9B26A74870B8BCC79A0AAB345C59CA3EB9B1C1312245AC9F025099430765DC6FFED05587E302FA3D9A2DB102BF0345B7075087FEBA403F49D61CF2838F1CD59D0F18C7A09FC64A4A021E88D3C27EB7FB98023AE6463D1E1FF15AB8FF752B6465231BBCB293EAF146A2BF5ABFE616F0E63D99D6192EA93208B1C28BDE6DA600DD3952A127E3E804A046F51CA122C03833C583DEEB1170AB312BFCADAEAA2D4C6912E29C0BD8D9D9241BBC0F59053353F95C10D31BAFACAC084396D257035976378236CF86CAAD4DDFD234944F7BDFE46F</Ticket> <TicketTimeout>30</TicketTimeout> <TwoFactorAllowedDestinations></TwoFactorAllowedDestinations> <TwoFactorStatus>5</TwoFactorStatus> </AuthenticateResponse>
        """.data(using: .utf8)!
        do {
            let response: AuthenticateResponse = try decoder.decode(AuthenticateResponse.self, from: data)
            let expected = AuthenticateResponse(accountID: "1394190", deviceTimeout: 10, displayName: "Joyce (Mom)", legalName: "Joyce Mychart", name: "Joyce Mychart", featureInformation: AuthenticateResponse.FeatureInformation(allowRxRefill: true, disabledFeatures: [], enabledFeatures: ["ACCOUNTDETAILS", "ACCOUNTDETAILS2"]))
            XCTAssertTrue(response == expected)
        } catch { XCTFail(error.localizedDescription) }
    }

    func testDecodingMessageList() {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase
        let data = """
        <GetMessageListResponse xmlns="http://schemas.datacontract.org/2004/07/Epic.MyChart.Mobile.DataContracts.Messages2017" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
            <LoadMore>false</LoadMore>
            <MessageList>
                <Message>
                    <Body xmlns="urn:Epic-com:MyChartMobile.2010.Services" />
                    <Date xmlns="urn:Epic-com:MyChartMobile.2010.Services">2018-12-15T14:14:00</Date>
                    <From xmlns="urn:Epic-com:MyChartMobile.2010.Services">
                        <HasProviderPhotoOnBlob>false</HasProviderPhotoOnBlob>
                        <IsPCP>false</IsPCP>
                        <LegalName />
                        <Name>System Generated Message</Name>
                        <OOCEndDate i:nil="true" />
                        <ObjectID>999MYCHT</ObjectID>
                        <PCPType i:nil="true" />
                        <ProviderPhotoURL />
                        <RecipTemplate>WPMessageRecipientTemplateUnknown</RecipTemplate>
                        <SerID />
                    </From>
                    <HasAttachments xmlns="urn:Epic-com:MyChartMobile.2010.Services">false</HasAttachments>
                    <HasIncompleteTask xmlns="urn:Epic-com:MyChartMobile.2010.Services">false</HasIncompleteTask>
                    <Name i:nil="true" xmlns="urn:Epic-com:MyChartMobile.2010.Services" />
                    <ObjectID xmlns="urn:Epic-com:MyChartMobile.2010.Services">7658044</ObjectID>
                    <Read xmlns="urn:Epic-com:MyChartMobile.2010.Services">true</Read>
                    <Subject xmlns="urn:Epic-com:MyChartMobile.2010.Services">New Questionnaire Available in MyAdvocateAurora</Subject>
                    <To xmlns="urn:Epic-com:MyChartMobile.2010.Services">
                        <HasProviderPhotoOnBlob>false</HasProviderPhotoOnBlob>
                        <IsPCP>false</IsPCP>
                        <LegalName>Joyce Mychart</LegalName>
                        <Name>Joyce Mychart</Name>
                        <OOCEndDate i:nil="true" />
                        <ObjectID>Z25381684</ObjectID>
                        <PCPType i:nil="true" />
                        <ProviderPhotoURL />
                        <RecipTemplate>WPMessageRecipientTemplateUnknown</RecipTemplate>
                        <SerID />
                    </To>
                    <isFuture xmlns="urn:Epic-com:MyChartMobile.2010.Services">false</isFuture>
                    <orgInfo xmlns:a="urn:Epic-com:MyChartMobile.2017.Services">
                        <a:OrganizationID>Zpk2sw9pQqhdsEB+WuJ4bQ==</a:OrganizationID>
                        <a:OrganizationName>Advocate Aurora Health - TST</a:OrganizationName>
                        <a:IsExternal>false</a:IsExternal>
                        <a:LogoUrl>https://mycharttst.aurora.org/chart/en-us/images/h2glogo.png</a:LogoUrl>
                        <a:OrganizationLinkType>0</a:OrganizationLinkType>
                        <a:LastRefreshDate i:nil="true" />
                    </orgInfo>
                </Message>
                <Message>
                    <Body xmlns="urn:Epic-com:MyChartMobile.2010.Services" />
                    <Date xmlns="urn:Epic-com:MyChartMobile.2010.Services">DATE2</Date>
                    <From xmlns="urn:Epic-com:MyChartMobile.2010.Services">
                        <HasProviderPhotoOnBlob>false</HasProviderPhotoOnBlob>
                        <IsPCP>false</IsPCP>
                        <LegalName />
                        <Name>System Generated Message</Name>
                        <OOCEndDate i:nil="true" />
                        <ObjectID>999MYCHT</ObjectID>
                        <PCPType i:nil="true" />
                        <ProviderPhotoURL />
                        <RecipTemplate>WPMessageRecipientTemplateUnknown</RecipTemplate>
                        <SerID />
                    </From>
                    <HasAttachments xmlns="urn:Epic-com:MyChartMobile.2010.Services">false</HasAttachments>
                    <HasIncompleteTask xmlns="urn:Epic-com:MyChartMobile.2010.Services">false</HasIncompleteTask>
                    <Name i:nil="true" xmlns="urn:Epic-com:MyChartMobile.2010.Services" />
                    <ObjectID xmlns="urn:Epic-com:MyChartMobile.2010.Services">7658044</ObjectID>
                    <Read xmlns="urn:Epic-com:MyChartMobile.2010.Services">true</Read>
                    <Subject xmlns="urn:Epic-com:MyChartMobile.2010.Services">New Questionnaire Available in MyAdvocateAurora</Subject>
                    <To xmlns="urn:Epic-com:MyChartMobile.2010.Services">
                        <HasProviderPhotoOnBlob>false</HasProviderPhotoOnBlob>
                        <IsPCP>false</IsPCP>
                        <LegalName>Joyce Mychart</LegalName>
                        <Name>Joyce Mychart</Name>
                        <OOCEndDate i:nil="true" />
                        <ObjectID>Z25381684</ObjectID>
                        <PCPType i:nil="true" />
                        <ProviderPhotoURL />
                        <RecipTemplate>WPMessageRecipientTemplateUnknown</RecipTemplate>
                        <SerID />
                    </To>
                    <isFuture xmlns="urn:Epic-com:MyChartMobile.2010.Services">false</isFuture>
                    <orgInfo xmlns:a="urn:Epic-com:MyChartMobile.2017.Services">
                        <a:OrganizationID>Zpk2sw9pQqhdsEB+WuJ4bQ==</a:OrganizationID>
                        <a:OrganizationName>Advocate Aurora Health - TST</a:OrganizationName>
                        <a:IsExternal>false</a:IsExternal>
                        <a:LogoUrl>https://mycharttst.aurora.org/chart/en-us/images/h2glogo.png</a:LogoUrl>
                        <a:OrganizationLinkType>0</a:OrganizationLinkType>
                        <a:LastRefreshDate i:nil="true" />
                    </orgInfo>
                </Message>
               </MessageList>
            <nextMessagesMap xmlns:a="urn:Epic-com:MyChartMobile.2017.Services">
                <a:IncrementalLoadingTracker>
                    <a:Organization>
                        <a:OrganizationID>Zpk2sw9pQqhdsEB+WuJ4bQ==</a:OrganizationID>
                        <a:OrganizationName>Advocate Aurora Health - TST</a:OrganizationName>
                        <a:IsExternal>false</a:IsExternal>
                        <a:LogoUrl>https://mycharttst.aurora.org/chart/en-us/images/h2glogo.png</a:LogoUrl>
                        <a:OrganizationLinkType>0</a:OrganizationLinkType>
                        <a:LastRefreshDate i:nil="true" />
                    </a:Organization>
                    <a:NextItemID>7657607^</a:NextItemID>
                    <a:Done>false</a:Done>
                </a:IncrementalLoadingTracker>
            </nextMessagesMap>
        </GetMessageListResponse>
        """.data(using: .utf8)!

        do {
            let response: GetMessageListResponse = try decoder.decode(GetMessageListResponse.self, from: data)
            let expected = GetMessageListResponse.init(messageList: [Message(date: "2018-12-15T14:14:00"), Message(date: "DATE2")])
            XCTAssertTrue(response == expected)
        } catch { XCTFail(error.localizedDescription) }
    }
}
