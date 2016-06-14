/**
 * Test Class for test for the Class: CaseNewButtonOverrideClass
 */
@isTest
private class Test_CaseNewButtonOverrideClass
{
    static testMethod void myUnitTest() 
    {
        ApexPages.StandardController controller;
        CaseNewButtonOverrideClass cnboc = new CaseNewButtonOverrideClass(controller);
        
        cnboc.newCasePage();

    }
}