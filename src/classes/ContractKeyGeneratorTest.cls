/**
 * Copyright (c) 2016 by PROS, Inc.  All Rights Reserved.
 * This software is the confidential and proprietary information of
 * PROS, Inc. ("Confidential Information").
 * You may not disclose such Confidential Information, and may only
 * use such Confidential Information in accordance with the terms of
 * the license agreement you entered into with PROS.

 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

@isTest
private class ContractKeyGeneratorTest {

    static testMethod void testGenerateKey() {

        ContractKeyGenerator keyGen = new ContractKeyGenerator();
        List<String> lineItemKeys = keyGen.generateKeys('201601,201602','service1,service2,service3');

        System.AssertEquals(2,lineItemKeys.size());
        System.AssertEquals('10',lineItemKeys[0]);
        System.AssertEquals('50',lineItemKeys[1]);


        lineItemKeys = keyGen.generateKeys('201604','service2,service3');
        System.AssertEquals(1,lineItemKeys.size());
        System.AssertEquals('90',lineItemKeys[0]);

    }

    static testMethod void testNullString() {

        ContractKeyGenerator keyGen = new ContractKeyGenerator();
        List<String> lineItemKeys = keyGen.generateKeys(null,'');

        System.AssertEquals(1,lineItemKeys.size());
        System.AssertEquals('10',lineItemKeys[0]);


        lineItemKeys = keyGen.generateKeys('',null);
        System.AssertEquals(1,lineItemKeys.size());
        System.AssertEquals('20',lineItemKeys[0]);

    }

}