/**********************************************************************
* Name:   	SG_TestDataGenerator
* Author: 	Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date: 	2009
* ======================================================
* ======================================================
* Purpose:
* This class is used to create test data. It is virtual so that it can be extended
*
* ======================================================
* ======================================================
* History:
* VERSION	DATE            INITIALS	DESCRIPTION/FEATURES ADDED
* 1.0     	2009	        CS			Initial Development
*
***********************************************************************/


public virtual class SG_TestDataGenerator
{
	//Always allow for the creation of one or more users
	private List<User> users;
	private Map<String,List<User>> profileToUserMap;

	private List<Lead> leads;
	private List<Account> accounts;
	private List<Contact> contacts;
	private List<Opportunity> opportunities;
	private Pricebook2 pricebook;
	private List<Product2> products;
	private List<PricebookEntry> pricebookEntries;
	private List<OpportunityLineItem> opportunityLineItems;
	private List<Asset> assets;
	private List<Order> orders;
	private List<OrderItem> orderLines;

	public Integer leadNum;
	public Integer accountNum;
	public Integer contactNum;
	public Integer opptyNum;
	public Integer opptyLineItemNum;
	public Integer productNum;
	public Integer pricebookEntryNum;
	public Integer assetNum;
	public Integer orderNum;

	public Integer userNum;
	public Integer meetingNoteNum;

	public SG_TestDataGenerator()
	{
		userNum = 2;
		accountNum = 2;
		contactNum = 2;
		opptyNum = 1;
		leadNum = 2;
		opptyLineItemNum = opptyNum * 2;
		productNum = Math.max(10,opptyLineItemNum);
		pricebookEntryNum = productNum;
		assetNum = accountNum;
		meetingNoteNum = 1;
		orderNum = 1;
	}

	public Map<String,List<User>> getProfileToUserMap(List<String> profileNames) {
		System.debug('@@@SG: getProfileToUserMap');
		getUsers(profileNames);
		return profileToUserMap;
	}

	//A user needs a profile
	public List<User> getUsers(List<String> profileNames){
		System.debug('@@@SG: getUsers');
		if(users == null) {
			users = new List<User>();

			//There are 3 classes of users, create at least one of each
			if(profileNames == null || profileNames.size() == 0) {
				profileNames = new List<String>();
				profileNames.add('Standard User');
			}

			System.debug('@@@SG: profileNames: ' + profileNames);

			Map<Id,Profile> profileMap;
			try {
				profileMap = new Map<Id,Profile>([select id, Name from profile where name IN :profileNames]);
			} catch (Exception exp) {
				//Can not test exceptions
				System.debug('@@@SG: Could not find profiles: ' + exp.getMessage());
			}

			if(profileMap == null || profileMap.size() == 0) {
				profileMap = new Map<Id,Profile>([select id, Name from profile where name = 'Standard User']);
			}

			System.debug('@@@SG: profileMap: ' + profileMap);

			//Untested - this should never happen, just 3x checking
			if(profileMap == null || profileMap.size() == 0) {
				System.assert(false,'Could not find profiles');
				return null;
			}

			if(userNum == null || userNum < profileMap.size()) {
				userNum = profileMap.size();
			}

			for(Integer i = 0; i < userNum; i++) {
				Integer profilePosition = Math.mod(i,profileMap.size());
				Integer random = Math.random().intValue();
				User u = getUser(profileMap.values()[profilePosition], 'User' + i.format() + random.format());
				users.add(u);
			}

			System.debug('@@@SG: inserting users');
			insert users;

			//Now build the user map
			profileToUserMap = new Map<String,List<User>>();

			for(User u : users) {
				if(profileToUserMap.containsKey(profileMap.get(u.ProfileId).Name)) {
					profileToUserMap.get(profileMap.get(u.ProfileId).Name).add(u);
				} else {
					List<User> tmpUsers = new List<User>();
					tmpUsers.add(u);
					profileToUserMap.put(profileMap.get(u.ProfileId).Name,tmpUsers);
				}
			}
		}
		return users;
	}

	private User getUser(Profile p, String uniqueName){
		System.debug('@@@SG: getUser');

		String orgId = (String)Userinfo.getOrganizationId();
		String uniqueEmail = uniqueName + '@' + orgId + '.net.test';

		User u = new User(alias = 'standt',
				email=uniqueEmail,
				emailencodingkey='UTF-8',
				lastname='Testing',
				languagelocalekey='en_US',
				localesidkey='en_US',
				profileid = p.Id,
				timezonesidkey='America/Los_Angeles',
				username=uniqueEmail);
		return u;
	}

	public Id getParentId(List<SObject> objects, Integer i)
	{
		Integer j = Math.mod(i,objects.size());
		SObject obj = objects[j];
		if(obj != null)
		{
			return (Id)obj.get('Id');
		}
		return null;
	}

	public List<Account> getAccounts(Boolean xCommit)
	{
		if(accounts == null) {
			accounts = new List<Account>();
			for(Integer i = 0; i < accountNum; i++) {
				Account a = new Account();
				a.Name = 'Test ' + i;
				a.BillingStreet = '1 Main St';
				a.BillingCity = 'Austin';
				a.BillingCountry = 'United States';
				a.BillingState = 'Texas';
				a.BillingPostalCode = '78731';

				a.ShippingStreet = '1 Main St';
				a.ShippingCity = 'Austin';
				a.ShippingCountry = 'United States';
				a.ShippingState = 'Texas';
				a.ShippingPostalCode = '78731';
				a.NumberOfEmployees = 0;

				accounts.add(a);

			}
			if(xCommit) insert accounts;
		}

		if(xCommit && accounts.size() > 0 && accounts[0].Id == null) insert accounts;

		return accounts;
	}

	public List<Contact> getContacts(Boolean xCommit) {
		if(contacts == null) {
			contacts = new List<Contact>();
			for(Integer i = 0; i < contactNum; i++) {
				Contact c = new Contact();
				c.FirstName = 'First ' + i;
				c.LastName = 'Last ' + i;
				c.Email = 'First.Last@fake.com.' + i;
				c.AccountId = getParentId(getAccounts(true),i);

				try
				{
					((SObject)c).put('Unit_Contact__c',1);
				}
				catch(Exception exp)
				{
					//Ignore if fields aren't there
				}

				contacts.add(c);
			}
			if(xCommit) insert contacts;
		}

		if(xCommit && contacts.size() > 0 && contacts[0].Id == null) insert contacts;

		return contacts;
	}

	public List<Opportunity> getOpportunities(Boolean xCommit, Id pricebookId)
	{
		if(opportunities == null) {
			opportunities = new List<Opportunity>();
			for(Integer i = 0; i < opptyNum; i++) {
				Opportunity o = new Opportunity();
				o.Name = 'Test ' + i;
				o.CloseDate = Date.today().addDays(1);
				o.StageName = '01-New';
				o.AccountId = getParentId(getAccounts(true),i);
				if(pricebookId != null)
				{
					o.Pricebook2Id = pricebookId;
				}

				opportunities.add(o);
			}
			if(xCommit) insert opportunities;
		}

		if(xCommit && opportunities.size() > 0 && opportunities[0].Id == null) insert opportunities;

		return opportunities;
	}

	public List<Opportunity> getOpportunities(Boolean xCommit) {
		return getOpportunities(xCommit, null);
	}

	public List<Product2> getProducts(Boolean xCommit) {

		if(products == null) {
			products = new List<Product2>();
			for(Integer i = 0; i < productNum; i++) {
				Product2 p = new Product2();
				p.IsActive = true;
				p.Name = 'Test Product ' + i;
				p.ProductCode = 'TestPCode ' + i;
				products.add(p);
			}
			if(xCommit) insert products;
		}

		if(xCommit && products.size() > 0 && products[0].Id == null) insert products;

		return products;
	}

	public Pricebook2 getPricebook(Boolean xCommit) {
		if(pricebook == null) {
			pricebook = new Pricebook2();
			pricebook.IsActive = true;
			pricebook.Name = 'Test Pricebook';
			if(xCommit) insert pricebook;
		}

		if(xCommit && pricebook.Id == null) insert pricebook;

		return pricebook;
	}

	public List<PricebookEntry> getPricebookEntries(Boolean xCommit) {

		if(pricebookEntries == null) {
			pricebookEntries = new List<PricebookEntry>();
			List<PricebookEntry> stdPricebookEntries = new List<PricebookEntry>();

			Id standardPBId = Test.getStandardPricebookId();
			for(Integer i = 0; i < pricebookEntryNum; i++) {
				PricebookEntry pbeStd = new PricebookEntry();
				pbeStd.IsActive = true;
				pbeStd.Pricebook2Id = standardPBId;
				System.assertNotEquals(null, pbeStd.Pricebook2Id,standardPBId);

				Integer j = Math.mod(i, getProducts(true).size());
				pbeStd.Product2Id = getProducts(true)[j].Id;
				System.assertNotEquals(null, pbeStd.Product2Id,getProducts(true)[j]);

				pbeStd.UnitPrice = i;
				pbeStd.UseStandardPrice = false;
				stdPricebookEntries.add(pbeStd);

				PricebookEntry pbe = new PricebookEntry();
				pbe.IsActive = true;
				pbe.Pricebook2Id = getPricebook(true).Id;
				System.assertNotEquals(null, pbe.Pricebook2Id,getPricebook(true));

				pbe.Product2Id = pbeStd.Product2Id;
				System.assertNotEquals(null, pbe.Product2Id,pbeStd);

				pbe.UnitPrice = i;
				pbe.UseStandardPrice = false;
				pricebookEntries.add(pbe);
			}
			insert stdPricebookEntries;
			if(xCommit) insert pricebookEntries;
		}

		if(xCommit && pricebookEntries.size() > 0 && pricebookEntries[0].Id == null) insert pricebookEntries;

		return pricebookEntries;
	}

	public List<OpportunityLineItem> getOpportunityLineItems(Boolean xCommit) {
		if(opportunityLineItems == null) {
			opportunityLineItems = new List<OpportunityLineItem>();
			for(Integer i = 0; i < opptyLineItemNum; i++) {
				OpportunityLineItem oli = new OpportunityLineItem();

				Integer j = Math.mod(i,getOpportunities(true).size());
				oli.OpportunityId = getOpportunities(true,getPricebook(true).Id)[j].Id;

				Integer k = Math.mod(i,getPricebookEntries(true).size());
				oli.PricebookEntryId = getPricebookEntries(true)[k].Id;

				oli.Quantity = i + 1;

				oli.UnitPrice = getPricebookEntries(true)[k].UnitPrice;

				opportunityLineItems.add(oli);
			}
			if(xCommit) insert opportunityLineItems;
		}

		if(xCommit && opportunityLineItems.size() > 0 && opportunityLineItems[0].Id == null) insert opportunityLineItems;

		return opportunityLineItems;
	}

	public List<Lead> getLeads(Boolean xCommit) {
		if(leads == null) {
			leads = new List<Lead>();
			for(Integer i = 0; i < leadNum; i++) {
				Lead l = new Lead();
				l.FirstName = 'First ' + i;
				l.LastName = 'Last ' + i;
				l.Email = 'email' + i + '@test.com';

				Integer j = Math.mod(i,getAccounts(true).size());
				Account a = getAccounts(true)[j];
				l.Company = a.Name;

				leads.add(l);
			}
			if(xCommit) insert leads;
		}

		if(xCommit && leads.size() > 0 && leads[0].Id == null) insert leads;

		return leads;
	}

	public List<Asset> getAssets(Boolean xCommit) {
		if(assets == null) {
			assets = new List<Asset>();
			for(Integer i = 0; i < assetNum; i++) {
				Asset a = new Asset();

				a.Name = 'Test' + i;

				Integer j = Math.mod(i,getAccounts(true).size());
				a.AccountId = getAccounts(true)[j].Id;

				Integer k = Math.mod(i,getProducts(true).size());
				a.Product2Id = getProducts(true)[k].Id;

				a.Quantity = i + 1;
				a.Price = 100 + i;
				a.Status = 'Active';
				a.PurchaseDate = Date.today().addDays(2);

				assets.add(a);
			}
			if(xCommit) insert assets;
		}

		if(xCommit && assets.size() > 0 && assets[0].Id == null) insert assets;

		return assets;
	}



	public List<Order> getOrders(Boolean xCommit) {
		return getOrders(xCommit, null);
	}

	public List<Order> getOrders(Boolean xCommit, Id pricebookId)
	{
		if(orders == null) {
			orders = new List<Order>();
			for(Integer i = 0; i < opptyNum; i++) {
				Order o = new Order();
				o.Name = 'Test ' + i;
				o.Status = 'Draft';
				o.EffectiveDate = Date.today();
				o.AccountId = getParentId(getAccounts(true),i);
				if(pricebookId != null)
				{
					o.Pricebook2Id = pricebookId;
				}

				orders.add(o);
			}
			if(xCommit) insert orders;
		}

		if(xCommit && orders.size() > 0 && orders[0].Id == null) insert orders;

		return orders;
	}


	public virtual void initAllTestData() {
		getUsers(null);
		getLeads(true);
		getAccounts(true);
		getContacts(true);
		getOpportunities(true);
		getPricebook(true);
		getProducts(true);
		getOpportunityLineItems(true);
		getAssets(true);
		getOrders(true, Test.getStandardPricebookId() );
		//  getOrderLines( true, null );
	}

}