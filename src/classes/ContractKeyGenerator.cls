/*
 * Copyright (c) 2016 by PROS, Inc.  All Rights Reserved.
 * This software is the confidential and proprietary information of
 * PROS, Inc. ("Confidential Information").
 * You may not disclose such Confidential Information, and may only
 * use such Confidential Information in accordance with the terms of
 * the license agreement you entered into with PROS.
 *
 * author Shawn Wang
 */

/**
                Opportunity
                Offer # 1001

                Opportunity Line Item
                Product         Services        Months             Target price
                ========        ============    ==============     =======
                P1              S1,S2           201601, 201602     1200
                P2              S1              201603             1400
                P3              S3              201604, 201605     2800
EXPAND AND
ORDER BY MONTH, PRODUCT, SERVICE

                   MONTH     PRODCUT&SERVICE
                  201601     10 P1 X
                  201601     20 S1
                  201601     30 S2
                  201602     40 P1 X
                  201602     50 S1
                  201602     60 S2
                  201603     70 P2 X
                  201603     80 S1
                  201604     90 P3 X
                  201604    100 S3
                  201605    110 P3 X
                  201605    120 S3

                SEND ONLY PRODUCTS
                |
                |
                \/
                CONTRACT_KEY    PRODUCT         TARGET
                ============    ========        ======
                 10             P1              1200
                 40             P1              1200
                 70             P2              1400
                 90             P3              2800
                 110            P3              2800


*/

public with sharing class ContractKeyGenerator {

    static final Integer KEY_MULTIPLIER = 10;
    static final String  DELIMITER = ',';
    Integer nextIndex = 1;
     

    public ContractKeyGenerator( ){}

    public List<String> generateKeys(String monthsStr, String servicesStr)
    {
        List<String> months = new List<String>{''};
        if (!String.isBlank(monthsStr)){
            months   = monthsStr.split(DELIMITER);
        }

        List<String> services =  new List<String>();
        if (!String.isBlank(servicesStr)){
            services = servicesStr.split(DELIMITER);
        }

        List<String> contractKeys = new List<String>();
        for (String month : months) {
            contractKeys.add(String.valueOf(KEY_MULTIPLIER * nextIndex));
            nextIndex ++;
            for (String service : services)
            {
                nextIndex ++;
            }
        }
       
        return contractKeys;
    }
}