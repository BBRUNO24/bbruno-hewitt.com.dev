@isTest
public class test_ctrlMultiSelectPickList{

    private static testMethod void testctrl_MultiSelectPickList() {
        Test.startTest();
        
        ctrl_MultiSelectPickList cls = new ctrl_MultiSelectPickList();
        List<SelectOption> SO = new List<SelectOption>();
        SO.add(new SelectOption('Test Option', 'Test Option'));
        cls.setselectedOptions(SO);
        List<SelectOption> resultOptions = cls.getselectedOptions();    
        cls.setAllOptions(SO);
        resultOptions = cls.getAllOptions();
        //ctrl_MultiSelectPickList.Options innerCls = new ctrl_MultiSelectPickList.Options();
        
        Test.stopTest();
    }
    
    static testMethod void MultiselectTest() {
        ctrl_MultiSelectPickList cls = new ctrl_MultiSelectPickList();
     
        Test.startTest();
        
        List<SelectOption> AllOptions = new List<SelectOption>();
        List<SelectOption> SelectedOptions = new List<SelectOption>();
        String toDeselet= 'ABC';
            for(Integer i=0;i<=10;i++)
            {
                SelectOption temp = new SelectOption(String.valueOf(i),String.valueOf(i));
                AllOptions.add(temp);
            }
            for(Integer i=6;i<10;i++)
            {
                SelectOption temp = new SelectOption(String.valueOf(i),String.valueOf(i));
                SelectedOptions.add(temp);
            }
            cls.setAllOptions(AllOptions);
            cls.setselectedOptions(SelectedOptions); 
            
            List<String> lstSelOpt = new List<String>();
            lstSelOpt.add('0');
            lstSelOpt.add('1');
            cls.selected = lstSelOpt;
            
            List<String> lstDeSelOpt = new List<String>();
            lstDeSelOpt.add('5');
            cls.deselected= lstDeSelOpt;

            cls.Selecting();
            cls.Deselecting();
            cls.getselectedOptions();
            cls.getAllOptions();
        
               
        Test.stopTest();
    }    
}