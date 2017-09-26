/**
 * Controller for OpportunityProdPricingCollarCalculation VF page embedded in  
 * OpportunityLineItem standard layout and price collar fees pdf generation 
 * 
 * Commented out code is original calculation logic from early spreadsheets 
 * which were scoped out but may be re-introduced when further calculations
 * are required.
 */ 

public with sharing class OptyProdPricingCollarCalculationCtlr { 

    // need user time zone offset to adjust datetime of posts being displayed because
    // they are all in GMT
    public static Integer getUserTimeZoneOffset() {
        return UserInfo.getTimeZone().getOffset(System.now())/(1000*60*60);
    }

    public OpportunityLineItem opportunity { get; set; }
/*
    public Map<Date, Date> etdMonthToExerciseDateMap { get; set; }

    public List<List<Date>> getExerciseDateDummyRow() {
        List<List<Date>> exerciseDateDummyRow = new List<List<Date>>();
        exerciseDateDummyRow.add(getExerciseDateList());
        return exerciseDateDummyRow;
    } 
    
    public List<Date> getEtdMonthDateListForExerciseDates() {
        List<Date> etdMonthDateList = new List<Date>();
        etdMonthDateList.addAll(etdMonthToExerciseDateMap.keySet());
        etdMonthDateList.sort();
        return etdMonthDateList; 
    }
    
    public List<Date> getExerciseDateList() {
        List<Date> exerciseDateList = new List<Date>();
        for (Date etdMonthDate : getEtdMonthDateListForExerciseDates()) {
            exerciseDateList.add(etdMonthToExerciseDateMap.get(etdMonthDate));
        }
        return exerciseDateList;
    }
*/
    public List<String> etdMonthDisplayList { get; set; }
    public List<Pricing_Collar_Calculation__c> floorPriceHeaderDisplayList { get; set; }
    //public Map<Decimal, List<Pricing_Collar_Calculation__c>> capPricesValueMap { get; set; }
    public List<List<Pricing_Collar_Calculation__c>> capPrices { get; set; }
    public List<List<Pricing_Collar_Calculation__c>> floorPrices { get; set; }
    //public List<List<Pricing_Collar_Calculation__c>> volumeAdjustments { get; set; }

    public List<List<Pricing_Collar_Calculation__c>> priceCollarFees { get; set; }

    //used to store the name of and flag to UI when a pdf attachment needs to be
    //generated
    public String attachmentPdfName { get; set; }

    public OptyProdPricingCollarCalculationCtlr (ApexPages.StandardController controller) {
        opportunity = (Opportunitylineitem)controller.getRecord();
        //allow auto-calculation of fees when rendering as pdf
        if (Apexpages.currentPage().getParameters().get('renderAs') == 'pdf') {
            calculatePriceCollarFees();
        }
        attachmentPdfName = null;
    }

    public PageReference calculatePriceCollarFees() {
        attachmentPdfName = null;
        opportunity = [Select OpportunityId, PricebookEntry.Name, Pricing_Collar_Product_Class__c, Last_Delivery_Date__c, ServiceDate, Quantity, Collar_First_Month__c, Collar_Last_Month__c From OpportunityLineItem Where Id = :opportunity.Id];
        
        //perform initial parameter validation and return apex message if invalid
        if (opportunity.Quantity > 2000) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Volume is greater than 2000. Please contact ' + Label.Price_Collar_Support_Contact_Text + ' for assistance.'));
            return null;
        }
        if (opportunity.Pricing_Collar_Product_Class__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Product Class ' + opportunity.Pricing_Collar_Product_Class__c + ' is not a valid Pricing Collar Product Class.'));
            return null;
        }
        if ((opportunity.Collar_First_Month__c == null) || (opportunity.Collar_Last_Month__c == null)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The First Shipment Date and/or Last Delivery Date are not valid.'));
            return null;
        }
 
        Integer numberOfEtdMonths = 0;
        //etdMonthToExerciseDateMap = new Map<Date, Date>();
        if ((opportunity.Last_Delivery_Date__c!= null) && (opportunity.ServiceDate != null) ) {
            numberOfEtdMonths = opportunity.ServiceDate.monthsBetween(opportunity.Last_Delivery_Date__c) + 1;
            Date currentEtdMonth = opportunity.ServiceDate;
            for (Integer i = 0; i < numberOfEtdMonths; i++) {
                //etdMonthToExerciseDateMap.put(currentEtdMonth, currentEtdMonth.addDays(-opportunity.Pricing_Collar_Exercise_Num_days_prior__c.intValue()));
                currentEtdMonth = currentEtdMonth.toStartOfMonth();
                currentEtdMonth = currentEtdMonth.addMonths(1);
            }
        }

        Set<String> etdMonthDisplaySet = new Set<String>();
        //capPricesValueMap = new Map<Decimal, List<Pricing_Collar_Calculation__c>>();
        String currentEtdMonthDisplay = null;
        etdMonthDisplayList = new List<String>();
        floorPriceHeaderDisplayList = new List<Pricing_Collar_Calculation__c>();
        
        Decimal currentCapPriceValue = null;
        Decimal currentFloorPriceValue = null;
        //Decimal currentVolumeAdjustment = null;
        
        capPrices = new List<List<Pricing_Collar_Calculation__c>>();
        floorPrices = new List<List<Pricing_Collar_Calculation__c>>();
        //volumeAdjustments = new List<List<Pricing_Collar_Calculation__c>>();
        priceCollarFees = new List<List<Pricing_Collar_Calculation__c>>();
        
        List<Pricing_Collar_Calculation__c> currentCapPrices = null;
        List<Pricing_Collar_Calculation__c> currentFloorPrices = null;
        //List<Pricing_Collar_Calculation__c> currentVolumeAdjustments = null;
        List<Pricing_Collar_Calculation__c> currentPriceCollars = null;
        
        //perform calculation only only for product class and selected start and end months
            for (Pricing_Collar_Calculation__c pcc : [
                    Select p.Type__c, p.Pricing_Collar_Product__c, p.Name_Value__c, p.Calculation_Value__c, p.Calculation_Date__c, p.Calculation_Date_Display__c 
                    From Pricing_Collar_Calculation__c p 
                    Where p.Pricing_Collar_Product__c = :opportunity.Pricing_Collar_Product_Class__c
                                    Order By p.Type__c, p.Name_Value__c, p.Calculation_Date__c]) {
                if ((pcc.Calculation_Date__c >= opportunity.Collar_First_Month__c) && (pcc.Calculation_Date__c <= opportunity.Collar_Last_Month__c)) {
                    if ((currentEtdMonthDisplay != pcc.Calculation_Date_Display__c) && (!etdMonthDisplaySet.contains(pcc.Calculation_Date_Display__c))) {
                        currentEtdMonthDisplay = pcc.Calculation_Date_Display__c;
                        etdMonthDisplaySet.add(currentEtdMonthDisplay);
                        etdMonthDisplayList.add(currentEtdMonthDisplay);
                    }
/*
                    if (pcc.Type__c == 'Volume Adjustment') {
                        if (currentVolumeAdjustment != pcc.Name_Value__c) {
                            currentVolumeAdjustment = pcc.Name_Value__c;
                            currentVolumeAdjustments = new List<Pricing_Collar_Calculation__c>();
                            volumeAdjustments.add(currentVolumeAdjustments);
                        }
                        currentVolumeAdjustments.add(pcc);
                    }
*/
                    if (pcc.Type__c == 'Cap Price') {
                        if (currentCapPriceValue != pcc.Name_Value__c) {
                            currentCapPriceValue = pcc.Name_Value__c;
                            currentCapPrices = new List<Pricing_Collar_Calculation__c>();
                            capPrices.add(currentCapPrices);
                            
                            /*
                            currentPriceCollars = new List<Pricing_Collar_Calculation__c>();
                            priceCollarFees.add(currentPriceCollars);
                            currentPriceCollars.add(new Pricing_Collar_Calculation__c(Name = pcc.Name, Name_Value__c = pcc.Name_Value__c, Calculation_Value__c = 1.1));
                            currentPriceCollars.add(new Pricing_Collar_Calculation__c(Name = pcc.Name, Name_Value__c = pcc.Name_Value__c, Calculation_Value__c = 1.1));
                            currentPriceCollars.add(new Pricing_Collar_Calculation__c(Name = pcc.Name, Name_Value__c = pcc.Name_Value__c, Calculation_Value__c = 1.1));
                            currentPriceCollars.add(new Pricing_Collar_Calculation__c(Name = pcc.Name, Name_Value__c = pcc.Name_Value__c, Calculation_Value__c = 1.1));
                            currentPriceCollars.add(new Pricing_Collar_Calculation__c(Name = pcc.Name, Name_Value__c = pcc.Name_Value__c, Calculation_Value__c = 1.1));
                            */
                        }
                        currentCapPrices.add(pcc);
                    }
                    if (pcc.Type__c == 'Floor Price') {
                        if (currentFloorPriceValue != pcc.Name_Value__c) {
                            currentFloorPriceValue = pcc.Name_Value__c;
                            currentFloorPrices = new List<Pricing_Collar_Calculation__c>();
                            floorPrices.add(currentFloorPrices);
                            floorPriceHeaderDisplayList.add(pcc);
                        }
                        currentFloorPrices.add(pcc);
                    }
    /*                      
                    if (!capPricesValueMap.containsKey(capPrice.Name_Value__c)) {
                        capPricesValueMap.put(capPrice.Name_Value__c, new List<Pricing_Collar_Calculation__c>());
                    }
                    capPricesValueMap.get(capPrice.Name_Value__c).add(capPrice);
                    if (capPrice.Calculation_Date__c != null) {
                        etdMonthDisplaySet.add(capPrice.Calculation_Date__c);
                    }
    */
                }
            }
    
            //create map of average floor prices by name value
            Map<String, Decimal> floorPriceAverages = new Map<String, Decimal>(); 
            for (List<Pricing_Collar_Calculation__c> floorPriceList : floorPrices) {
                String floorPriceName = null;
                Decimal floorPriceTotal = 0;
                Integer floorPriceCount = 0;
                for (Pricing_Collar_Calculation__c floorPrice: floorPriceList) {
                    floorPriceName = floorPrice.Name_Value__c + '';
                    floorPriceTotal = floorPriceTotal + floorPrice.Calculation_Value__c;
                    floorPriceCount++;
                }
                floorPriceAverages.put(floorPriceName, floorPriceTotal/floorPriceCount);
            }
//system.debug('!!floorPriceAverages=' + floorPriceAverages);

            //create map of average cap prices by name value
            Map<String, Decimal> capPriceAverages = new Map<String, Decimal>(); 
            for (List<Pricing_Collar_Calculation__c> capPriceList : capPrices) {
                String capPriceName = null;
                Decimal capPriceNameValue = null;
                Decimal capPriceTotal = 0;
                Integer capPriceCount = 0;
                for (Pricing_Collar_Calculation__c capPrice: capPriceList) {
                    capPriceName = capPrice.Name_Value__c + '';
                    capPriceNameValue = capPrice.Name_Value__c;
                    capPriceTotal = capPriceTotal + capPrice.Calculation_Value__c;
                    capPriceCount++;
                }
                Decimal capPriceAverage = capPriceTotal/capPriceCount;
                capPriceAverages.put(capPriceName, capPriceTotal/capPriceCount);
                
                currentPriceCollars = new List<Pricing_Collar_Calculation__c>();
                for (Pricing_Collar_Calculation__c floorPricePcc: floorPriceHeaderDisplayList) {
                    decimal floorPriceAverage = floorPriceAverages.get(floorPricePcc.Name_Value__c + '');
                    decimal CollarFeeCalculated =0;
                    //Rules by CRT team: Fees below 10 should always be displayed as 10, cannot go below this nominal fee.
                    If((capPriceAverage - floorPriceAverage)<10)
                    {  
                         CollarFeeCalculated =10;
                    } 
                    else
                    {
                        CollarFeeCalculated = capPriceAverage - floorPriceAverage;
                    }
                    //currentPriceCollars.add(new Pricing_Collar_Calculation__c( Name_Value__c = capPriceNameValue, Calculation_Value__c = capPriceAverage - floorPriceAverage));
                    currentPriceCollars.add(new Pricing_Collar_Calculation__c( Name_Value__c = capPriceNameValue, Calculation_Value__c = CollarFeeCalculated));
                }
                priceCollarFees.add(currentPriceCollars);
            }

//system.debug('!!capPriceAverages=' + capPriceAverages);
//system.debug('!!priceCollarFees=' + priceCollarFees);

/*
            etdMonthDisplayList = new List<Date>();
            etdMonthDisplayList.addAll(etdMonthDisplaySet);
            etdMonthDisplayList.sort();
            List<Decimal> capPricesValueDisplayList = new List<Decimal>();
            capPricesValueDisplayList.addAll(capPricesValueMap.keySet());
            capPricesValueDisplayList.sort();
            capPrices = new List<List<Pricing_Collar_Calculation__c>>();
            for (Decimal cpv : capPricesValueDisplayList) {
                capPrices.add(capPricesValueMap.get(cpv));
            }
*/
//system.debug('!!priceCollarFees=' + priceCollarFees);
        if (priceCollarFees.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please enter valid pricing collars parameters to calculate fees.'));
        }
//system.debug('!!ApexPages.getMessages()=' + ApexPages.getMessages());
        if (!ApexPages.hasMessages()) {
            attachmentPdfName = opportunity.PricebookEntry.Name + ' - ' + System.now();
        }

        return null;
    }

    public PageReference savePricingCollarFeesAsPdfAttachment() {
        if (attachmentPdfName != null) {
            Blob pdfBlob = getPageAsBlob('/apex/OpportunityProdPricingCollarPdf?id=' + opportunity.Id + '&renderAs=pdf');
            Attachment pdfAttachment = saveBlobAsAttachment(pdfBlob, 'application/pdf', opportunity.OpportunityId);
            attachmentPdfName = null;
        }
        return null;
    }

    public Blob getPageAsBlob(String pageUrl) {
        PageReference pdfPage = new PageReference(pageUrl);
        Blob pdfBlob = null;
        if (!Test.isRunningTest()) {
            pdfBlob = pdfPage.getContentAsPDF();
        } else {
            pdfBlob = Blob.valueOf('test');
        }
        return pdfBlob;
    }
    
    public Attachment saveBlobAsAttachment(Blob blobToAttach, String contentType, Id parentId) {
        Attachment blobAttach = new Attachment();        
        blobAttach.Name = attachmentPdfName;
        blobAttach.Body = blobToAttach;
        blobAttach.ContentType = contentType;
        blobAttach.ParentId = parentId;
        insert blobAttach;
        return blobAttach;
    }

}