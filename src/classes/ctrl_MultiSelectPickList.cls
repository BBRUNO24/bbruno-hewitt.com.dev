public with sharing class ctrl_MultiSelectPickList 
{
    public String Label{get; set;}
    
    public List<String> selected{get; set;}   
    public List<String> deselected{get; set;} 
    
    public SelectOption Available { get; set; }   // The first value of available list
    public SelectOption Chosen { get; set; }      // The first value of chosen list 
    
    // A property "selectedOptions"
    public List<SelectOption> selectedOptions = null; 
    public List<SelectOption> getselectedOptions()
    {        return selectedOptions;    }
    public void setselectedOptions(List<SelectOption> value)
    {        selectedOptions = value;    }


    // A property "AllOptions"
    private List<SelectOption> AllOptions = null;
    public List<SelectOption> getAllOptions()
    {        return AllOptions;    }
    public void setAllOptions(List<SelectOption> value)
    {        AllOptions = value;    }

    // Constructor 
    public ctrl_MultiSelectPickList()
    {
        System.Debug('CPL Calling constructor ctrl_MultiSelectPickList()');
        selected = new List<String>();
        deselected = new List<String>();
        
        Available = new SelectOption('Available','Available', true);
        Chosen = new SelectOption('Chosen','Chosen', true);
        
        //System.Debug('CPL  Exiting constructor ctrl_MultiSelectPickList()');
        
    }

    // A Select list "Available" selection functionality
    public void Selecting() 
    {    
        //System.Debug('CPL Calling Selecting()');
        try
        {
            for(String toSelect: selected) 
            {  
                Integer i = 0;  
                While(i < AllOptions.size()) 
                {  
                    if(AllOptions[i].getvalue()==toSelect) 
                    {   
                        selectedOptions.add(new SelectOption(toSelect,toSelect));   
                        AllOptions.remove(i);
                        break;  
                    }                      
                    i++;  
                } 
            }
            selectedOptions = Sort(selectedOptions); 
            System.Debug('CPL chosen box has : ' + selectedOptions);
        }
        catch(Exception exp)
        {
            System.Debug('Exception in :' + exp.getMessage());
        }
        //System.Debug('CPL Exiting Selecting()');
    }

    // A Select list "Chosen" de-selection functionality
    public void Deselecting() 
    {  
        //System.Debug('CPL Calling Deselecting()');
        try
        {
            for(String toDeselect: deselected) 
            {              
                Integer i = 0;  
                While(i < selectedOptions.size()) 
                {  
                    if(selectedOptions[i].getvalue() == toDeselect) 
                    {   
                        AllOptions.add(new SelectOption(toDeselect, toDeselect));   
                        selectedOptions.remove(i);  
                        break;
                    }                      
                    i++;  
                } 
            }
            AllOptions = sort(AllOptions);  
        }
        catch(Exception exp)
        {
            System.Debug('Exception in :' + exp.getMessage());
        }
        //System.Debug('CPL Exiting Deselecting()');
    } 

    // A method to sort list of "SelectOptions"
    public List<SelectOption> Sort(List<SelectOption> lstToSort)
    {
        System.Debug('Original List: ' + lstToSort);
        List<SelectOption> returnList = new List<SelectOption>();
        try
        {
            // Convert SelectOption list To String List
            List<String> convertedList = new List<String>();
            for(SelectOption opt: lstToSort)
            {
                convertedList.add(opt.getLabel()); 
            }
    
            convertedList = sortList(convertedList);
            System.Debug('Convert and Sorted: ' + convertedList);
    
            // Convert String List to SelectOption list
            for(String strOpt: convertedList)
            {
                returnList.add(new SelectOption(strOpt,strOpt)); 
            }
            System.Debug('Returning: ' + returnList);
        }
        catch(Exception exp)
        {
            System.Debug('Exception in Sort(): ' + exp.getMessage());
        }
        return returnList;
    }

    // A method to list of strings with ignorecase
    private List<String> sortList(List<String> competitors) 
    {
        Map<String, String> interimMap = new Map<String, String>();
        List<String> interimList = new List<String>();
        
        for(String comp : Competitors)
        {
            interimMap.put(comp.toUpperCase(), comp);
            interimList.add(comp.toUpperCase());
        }

        interimList.sort();
    
        // purge the initial competitors list
        competitors.clear();
                    
        for(String comp : interimList){
            competitors.add(interimMap.get(comp));
        }
                    
        return competitors;
    }
}