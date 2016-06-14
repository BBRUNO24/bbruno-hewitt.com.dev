/**
 * An Apex controller that copies out-of-the-box data into a custom revenue schedule object for the purpose of reporting.
 */
public with sharing class OppLineItemScheduleRevenueController {
    public static Boolean newRevScheduleObject = true;

    public static void OppsToUpdate(List<Opportunity> newOpps) {
        for (Opportunity opp: newOpps) {
            if(opp.Workday_Opportunity__c == true) {
               System.Debug('OppLineItemScheduleRevenueController - Found Workday opportunity.');
               Revenue_Scheduling__c revScheduling = OppLineItemScheduleRevenueUpdate(opp);
               if(newRevScheduleObject){
                    System.Debug('OppLineItemScheduleRevenueController - Inserting custom revenue schedule object.');
                    insert revScheduling;
               }else{
                    System.Debug('OppLineItemScheduleRevenueController - Updating custom revenue schedule object.');
                    update revScheduling;
               }
            }
        }      
    }
    
    private static Revenue_Scheduling__c OppLineItemScheduleRevenueUpdate(Opportunity opp){
        Revenue_Scheduling__c revSchedulingObj = new Revenue_Scheduling__c();
        revSchedulingObj.Opportunity__c = opp.Id;
        revSchedulingObj.Jan_13_Rev__c = 0;
        revSchedulingObj.Feb_13_Rev__c = 0;
        revSchedulingObj.Mar_13_Rev__c = 0;
        revSchedulingObj.Apr_13_Rev__c = 0;
        revSchedulingObj.May_13_Rev__c = 0;
        revSchedulingObj.Jun_13_Rev__c = 0;
        revSchedulingObj.Jul_13_Rev__c = 0;
        revSchedulingObj.Aug_13_Rev__c = 0;
        revSchedulingObj.Sep_13_Rev__c = 0;
        revSchedulingObj.Oct_13_Rev__c = 0;
        revSchedulingObj.Nov_13_Rev__c = 0;
        revSchedulingObj.Dec_13_Rev__c = 0;
        revSchedulingObj.Jan_14_Rev__c = 0;
        revSchedulingObj.Feb_14_Rev__c = 0;
        revSchedulingObj.Mar_14_Rev__c = 0;
        revSchedulingObj.Apr_14_Rev__c = 0;
        revSchedulingObj.May_14_Rev__c = 0;
        revSchedulingObj.Jun_14_Rev__c = 0;
        revSchedulingObj.Jul_14_Rev__c = 0;
        revSchedulingObj.Aug_14_Rev__c = 0;
        revSchedulingObj.Sep_14_Rev__c = 0;
        revSchedulingObj.Oct_14_Rev__c = 0;
        revSchedulingObj.Nov_14_Rev__c = 0;
        revSchedulingObj.Dec_14_Rev__c = 0;
        revSchedulingObj.Jan_15_Rev__c = 0;
        revSchedulingObj.Feb_15_Rev__c = 0;
        revSchedulingObj.Mar_15_Rev__c = 0;
        revSchedulingObj.Apr_15_Rev__c = 0;
        revSchedulingObj.May_15_Rev__c = 0;
        revSchedulingObj.Jun_15_Rev__c = 0;
        revSchedulingObj.Jul_15_Rev__c = 0;
        revSchedulingObj.Aug_15_Rev__c = 0;
        revSchedulingObj.Sep_15_Rev__c = 0;
        revSchedulingObj.Oct_15_Rev__c = 0;
        revSchedulingObj.Nov_15_Rev__c = 0;
        revSchedulingObj.Dec_15_Rev__c = 0;
        revSchedulingObj.Jan_16_Rev__c = 0;
        revSchedulingObj.Feb_16_Rev__c = 0;
        revSchedulingObj.Mar_16_Rev__c = 0;
        revSchedulingObj.Apr_16_Rev__c = 0;
        revSchedulingObj.May_16_Rev__c = 0;
        revSchedulingObj.Jun_16_Rev__c = 0;
        revSchedulingObj.Jul_16_Rev__c = 0;
        revSchedulingObj.Aug_16_Rev__c = 0;
        revSchedulingObj.Sep_16_Rev__c = 0;
        revSchedulingObj.Oct_16_Rev__c = 0;
        revSchedulingObj.Nov_16_Rev__c = 0;
        revSchedulingObj.Dec_16_Rev__c = 0;
        revSchedulingObj.Jan_17_Rev__c = 0;
        revSchedulingObj.Feb_17_Rev__c = 0;
        revSchedulingObj.Mar_17_Rev__c = 0;
        revSchedulingObj.Apr_17_Rev__c = 0;
        revSchedulingObj.May_17_Rev__c = 0;
        revSchedulingObj.Jun_17_Rev__c = 0;
        revSchedulingObj.Jul_17_Rev__c = 0;
        revSchedulingObj.Aug_17_Rev__c = 0;
        revSchedulingObj.Sep_17_Rev__c = 0;
        revSchedulingObj.Oct_17_Rev__c = 0;
        revSchedulingObj.Nov_17_Rev__c = 0;
        revSchedulingObj.Dec_17_Rev__c = 0;
        revSchedulingObj.Jan_18_Rev__c = 0;
        revSchedulingObj.Feb_18_Rev__c = 0;
        revSchedulingObj.Mar_18_Rev__c = 0;
        revSchedulingObj.Apr_18_Rev__c = 0;
        revSchedulingObj.May_18_Rev__c = 0;
        revSchedulingObj.Jun_18_Rev__c = 0;
        revSchedulingObj.Jul_18_Rev__c = 0;
        revSchedulingObj.Aug_18_Rev__c = 0;
        revSchedulingObj.Sep_18_Rev__c = 0;
        revSchedulingObj.Oct_18_Rev__c = 0;
        revSchedulingObj.Nov_18_Rev__c = 0;
        revSchedulingObj.Dec_18_Rev__c = 0;
        //tempRevScheduling.add(revSchedulingObj);

        OpportunityLineItem[] oppLineItems = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];

        if(oppLineItems != null){
            System.Debug('OppLineItemScheduleRevenueController - Found ' + oppLineItems.size() + ' OpportunityLineItems with OpportunityId of: ' + opp.Id + '.');
            Integer count = 0;
            for(OpportunityLineItem oli: oppLineItems){
                OpportunityLineItemSchedule[] oppLineItemSchedules = [SELECT Id,Revenue,ScheduleDate FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId = :oli.Id];
                Revenue_Scheduling__c[] currentRevScheduling = [SELECT Apr_13_Rev__c,Apr_14_Rev__c,Apr_15_Rev__c,Apr_16_Rev__c,Apr_17_Rev__c,Apr_18_Rev__c,Aug_13_Rev__c,
                    Aug_14_Rev__c,Aug_15_Rev__c,Aug_16_Rev__c,Aug_17_Rev__c,Aug_18_Rev__c,Dec_13_Rev__c,Dec_14_Rev__c,
                    Dec_15_Rev__c,Dec_16_Rev__c,Dec_17_Rev__c,Dec_18_Rev__c,Feb_13_Rev__c,Feb_14_Rev__c,Feb_15_Rev__c,
                    Feb_16_Rev__c,Feb_17_Rev__c,Feb_18_Rev__c,Jan_13_Rev__c,Jan_14_Rev__c,Jan_15_Rev__c,Jan_16_Rev__c,
                    Jan_17_Rev__c,Jan_18_Rev__c,Jul_13_Rev__c,Jul_14_Rev__c,Jul_15_Rev__c,Jul_16_Rev__c,Jul_17_Rev__c,
                    Jul_18_Rev__c,Jun_13_Rev__c,Jun_14_Rev__c,Jun_15_Rev__c,Jun_16_Rev__c,Jun_17_Rev__c,Jun_18_Rev__c,
                    Mar_13_Rev__c,Mar_14_Rev__c,Mar_15_Rev__c,Mar_16_Rev__c,Mar_17_Rev__c,Mar_18_Rev__c,May_13_Rev__c,
                    May_14_Rev__c,May_15_Rev__c,May_16_Rev__c,May_17_Rev__c,May_18_Rev__c,Nov_13_Rev__c,Nov_14_Rev__c,
                    Nov_15_Rev__c,Nov_16_Rev__c,Nov_17_Rev__c,Nov_18_Rev__c,Oct_13_Rev__c,Oct_14_Rev__c,Oct_15_Rev__c,
                    Oct_16_Rev__c,Oct_17_Rev__c,Oct_18_Rev__c,OpportunityLineItemId__c,Opportunity__c,Sep_13_Rev__c,
                    Sep_14_Rev__c,Sep_15_Rev__c,Sep_16_Rev__c,Sep_17_Rev__c,Sep_18_Rev__c FROM Revenue_Scheduling__c 
                    WHERE OpportunityLineItemId__c = :oli.Id];
                
                System.Debug('OppLineItemScheduleRevenueController - Found ' + currentRevScheduling.size() + ' current custom revenue schedule objects.');
                System.Debug('OppLineItemScheduleRevenueController - oppLineItems.size() = ' + oppLineItems.size() + ' and count = ' + count + '.');
                if(currentRevScheduling.size() > 1 && oppLineItems.size() != count){
                    System.Debug('OppLineItemScheduleRevenueController - Deleting extra custom revenue schedule object.');
                    for(Integer j = 1; j < currentRevScheduling.size(); j++){
                        delete currentRevScheduling[j];
                    }
                    newRevScheduleObject = false;
                }else if(!currentRevScheduling.isEmpty()){
                    ClearRevSchedule(currentRevScheduling[0]);
                    newRevScheduleObject = false;
                }

                count++;
                revSchedulingObj.OpportunityLineItemId__c = oli.Id;
                if(!currentRevScheduling.isEmpty()){
                    revSchedulingObj.Id = currentRevScheduling[currentRevScheduling.size()-1].Id;
                }

                if(oppLineItemSchedules != null){
                    System.Debug('OppLineItemScheduleRevenueController - Found ' + oppLineItemSchedules.size() + ' OpportunityLineItemSchedules with OpportunityLineItemId of : ' + oli.Id + '.');
                    Set<OpportunityLineItemSchedule> olisDates = new Set<OpportunityLineItemSchedule>();
                    olisDates = CombineOppLineItemScheduleRevenueItems(oppLineItemSchedules); 
                    
                    System.Debug('OppLineItemScheduleRevenueController - Found ' + olisDates.size() + ' Opportunity Line Item Schedule Dates.');
                    for(OpportunityLineItemSchedule olis: olisDates){                       
                        Date dt = olis.ScheduleDate;
                        System.Debug('OppLineItemScheduleRevenueController - Updating Revenue_Scheduling__c scheduled date of - ' + dt.month() + '/' + dt.year() + ' with ' + olis.Revenue + '.');
                        if(dt.month() == 1 && dt.year() == 2013){
                            revSchedulingObj.Jan_13_Rev__c += olis.Revenue;
                        }else if(dt.month() == 2 && dt.year() == 2013){
                            revSchedulingObj.Feb_13_Rev__c += olis.Revenue;
                        }else if(dt.month() == 3 && dt.year() == 2013){
                            revSchedulingObj.Mar_13_Rev__c += olis.Revenue;
                        }else if(dt.month() == 4 && dt.year() == 2013){
                            revSchedulingObj.Apr_13_Rev__c += olis.Revenue;
                        }else if(dt.month() == 5 && dt.year() == 2013){
                            revSchedulingObj.May_13_Rev__c += olis.Revenue;
                        }else if(dt.month() == 6 && dt.year() == 2013){
                            revSchedulingObj.Jun_13_Rev__c += olis.Revenue;
                        }else if(dt.month() == 7 && dt.year() == 2013){
                            revSchedulingObj.Jul_13_Rev__c += olis.Revenue;
                        }else if(dt.month() == 8 && dt.year() == 2013){
                            revSchedulingObj.Aug_13_Rev__c += olis.Revenue;
                        }else if(dt.month() == 9 && dt.year() == 2013){
                            revSchedulingObj.Sep_13_Rev__c += olis.Revenue;
                        }else if(dt.month() == 10 && dt.year() == 2013){
                            revSchedulingObj.Oct_13_Rev__c += olis.Revenue;
                        }else if(dt.month() == 11 && dt.year() == 2013){
                            revSchedulingObj.Nov_13_Rev__c += olis.Revenue;
                        }else if(dt.month() == 12 && dt.year() == 2013){
                            revSchedulingObj.Dec_13_Rev__c += olis.Revenue;
                        }else if(dt.month() == 1 && dt.year() == 2014){
                            revSchedulingObj.Jan_14_Rev__c += olis.Revenue;
                        }else if(dt.month() == 2 && dt.year() == 2014){
                            revSchedulingObj.Feb_14_Rev__c += olis.Revenue;
                        }else if(dt.month() == 3 && dt.year() == 2014){
                            revSchedulingObj.Mar_14_Rev__c += olis.Revenue;
                        }else if(dt.month() == 4 && dt.year() == 2014){
                            revSchedulingObj.Apr_14_Rev__c += olis.Revenue;
                        }else if(dt.month() == 5 && dt.year() == 2014){
                            revSchedulingObj.May_14_Rev__c += olis.Revenue;
                        }else if(dt.month() == 6 && dt.year() == 2014){
                            revSchedulingObj.Jun_14_Rev__c += olis.Revenue;
                        }else if(dt.month() == 7 && dt.year() == 2014){
                            revSchedulingObj.Jul_14_Rev__c += olis.Revenue;
                        }else if(dt.month() == 8 && dt.year() == 2014){
                            revSchedulingObj.Aug_14_Rev__c += olis.Revenue;
                        }else if(dt.month() == 9 && dt.year() == 2014){
                            revSchedulingObj.Sep_14_Rev__c += olis.Revenue;
                        }else if(dt.month() == 10 && dt.year() == 2014){
                            revSchedulingObj.Oct_14_Rev__c += olis.Revenue;
                        }else if(dt.month() == 11 && dt.year() == 2014){
                            revSchedulingObj.Nov_14_Rev__c += olis.Revenue;
                        }else if(dt.month() == 12 && dt.year() == 2014){
                            revSchedulingObj.Dec_14_Rev__c += olis.Revenue;
                        }else if(dt.month() == 1 && dt.year() == 2015){
                            revSchedulingObj.Jan_15_Rev__c += olis.Revenue;
                        }else if(dt.month() == 2 && dt.year() == 2015){
                            revSchedulingObj.Feb_15_Rev__c += olis.Revenue;
                        }else if(dt.month() == 3 && dt.year() == 2015){
                            revSchedulingObj.Mar_15_Rev__c += olis.Revenue;
                        }else if(dt.month() == 4 && dt.year() == 2015){
                            revSchedulingObj.Apr_15_Rev__c += olis.Revenue;
                        }else if(dt.month() == 5 && dt.year() == 2015){
                            revSchedulingObj.May_15_Rev__c += olis.Revenue;
                        }else if(dt.month() == 6 && dt.year() == 2015){
                            revSchedulingObj.Jun_15_Rev__c += olis.Revenue;
                        }else if(dt.month() == 7 && dt.year() == 2015){
                            revSchedulingObj.Jul_15_Rev__c += olis.Revenue;
                        }else if(dt.month() == 8 && dt.year() == 2015){
                            revSchedulingObj.Aug_15_Rev__c += olis.Revenue;
                        }else if(dt.month() == 9 && dt.year() == 2015){
                            revSchedulingObj.Sep_15_Rev__c += olis.Revenue;
                        }else if(dt.month() == 10 && dt.year() == 2015){
                            revSchedulingObj.Oct_15_Rev__c += olis.Revenue;
                        }else if(dt.month() == 11 && dt.year() == 2015){
                            revSchedulingObj.Nov_15_Rev__c += olis.Revenue;
                        }else if(dt.month() == 12 && dt.year() == 2015){
                            revSchedulingObj.Dec_15_Rev__c += olis.Revenue;
                        }else if(dt.month() == 1 && dt.year() == 2016){
                            revSchedulingObj.Jan_16_Rev__c += olis.Revenue;
                        }else if(dt.month() == 2 && dt.year() == 2016){
                            revSchedulingObj.Feb_16_Rev__c += olis.Revenue;
                        }else if(dt.month() == 3 && dt.year() == 2016){
                            revSchedulingObj.Mar_16_Rev__c += olis.Revenue;
                        }else if(dt.month() == 4 && dt.year() == 2016){
                            revSchedulingObj.Apr_16_Rev__c += olis.Revenue;
                        }else if(dt.month() == 5 && dt.year() == 2016){
                            revSchedulingObj.May_16_Rev__c += olis.Revenue;
                        }else if(dt.month() == 6 && dt.year() == 2016){
                            revSchedulingObj.Jun_16_Rev__c += olis.Revenue;
                        }else if(dt.month() == 7 && dt.year() == 2016){
                            revSchedulingObj.Jul_16_Rev__c += olis.Revenue;
                        }else if(dt.month() == 8 && dt.year() == 2016){
                            revSchedulingObj.Aug_16_Rev__c += olis.Revenue;
                        }else if(dt.month() == 9 && dt.year() == 2016){
                            revSchedulingObj.Sep_16_Rev__c += olis.Revenue;
                        }else if(dt.month() == 10 && dt.year() == 2016){
                            revSchedulingObj.Oct_16_Rev__c += olis.Revenue;
                        }else if(dt.month() == 11 && dt.year() == 2016){
                            revSchedulingObj.Nov_16_Rev__c += olis.Revenue;
                        }else if(dt.month() == 12 && dt.year() == 2016){
                            revSchedulingObj.Dec_16_Rev__c += olis.Revenue;
                        }else if(dt.month() == 1 && dt.year() == 2017){
                            revSchedulingObj.Jan_17_Rev__c += olis.Revenue;
                        }else if(dt.month() == 2 && dt.year() == 2017){
                            revSchedulingObj.Feb_17_Rev__c += olis.Revenue;
                        }else if(dt.month() == 3 && dt.year() == 2017){
                            revSchedulingObj.Mar_17_Rev__c += olis.Revenue;
                        }else if(dt.month() == 4 && dt.year() == 2017){
                            revSchedulingObj.Apr_17_Rev__c += olis.Revenue;
                        }else if(dt.month() == 5 && dt.year() == 2017){
                            revSchedulingObj.May_17_Rev__c += olis.Revenue;
                        }else if(dt.month() == 6 && dt.year() == 2017){
                            revSchedulingObj.Jun_17_Rev__c += olis.Revenue;
                        }else if(dt.month() == 7 && dt.year() == 2017){
                            revSchedulingObj.Jul_17_Rev__c += olis.Revenue;
                        }else if(dt.month() == 8 && dt.year() == 2017){
                            revSchedulingObj.Aug_17_Rev__c += olis.Revenue;
                        }else if(dt.month() == 9 && dt.year() == 2017){
                            revSchedulingObj.Sep_17_Rev__c += olis.Revenue;
                        }else if(dt.month() == 10 && dt.year() == 2017){
                            revSchedulingObj.Oct_17_Rev__c += olis.Revenue;
                        }else if(dt.month() == 11 && dt.year() == 2017){
                            revSchedulingObj.Nov_17_Rev__c += olis.Revenue;
                        }else if(dt.month() == 12 && dt.year() == 2017){
                            revSchedulingObj.Dec_17_Rev__c += olis.Revenue;
                        }else if(dt.month() == 1 && dt.year() == 2018){
                            revSchedulingObj.Jan_18_Rev__c += olis.Revenue;
                        }else if(dt.month() == 2 && dt.year() == 2018){
                            revSchedulingObj.Feb_18_Rev__c += olis.Revenue;
                        }else if(dt.month() == 3 && dt.year() == 2018){
                            revSchedulingObj.Mar_18_Rev__c += olis.Revenue;
                        }else if(dt.month() == 4 && dt.year() == 2018){
                            revSchedulingObj.Apr_18_Rev__c += olis.Revenue;
                        }else if(dt.month() == 5 && dt.year() == 2018){
                            revSchedulingObj.May_18_Rev__c += olis.Revenue;
                        }else if(dt.month() == 6 && dt.year() == 2018){
                            revSchedulingObj.Jun_18_Rev__c += olis.Revenue;
                        }else if(dt.month() == 7 && dt.year() == 2018){
                            revSchedulingObj.Jul_18_Rev__c += olis.Revenue;
                        }else if(dt.month() == 8 && dt.year() == 2018){
                            revSchedulingObj.Aug_18_Rev__c += olis.Revenue;
                        }else if(dt.month() == 9 && dt.year() == 2018){
                            revSchedulingObj.Sep_18_Rev__c += olis.Revenue;
                        }else if(dt.month() == 10 && dt.year() == 2018){
                            revSchedulingObj.Oct_18_Rev__c += olis.Revenue;
                        }else if(dt.month() == 11 && dt.year() == 2018){
                            revSchedulingObj.Nov_18_Rev__c += olis.Revenue;
                        }else if(dt.month() == 12 && dt.year() == 2018){
                            revSchedulingObj.Dec_18_Rev__c += olis.Revenue;
                        }
                    }
                }
            } 
        }
        return revSchedulingObj;
    }

    private static void ClearRevSchedule(Revenue_Scheduling__c revScheduling){
        System.Debug('OppLineItemScheduleRevenueController - Clearing Revenue_Scheduling__c revenue values to account for deletes.');
        revScheduling.Jan_13_Rev__c = null; 
        revScheduling.Feb_13_Rev__c = null;
        revScheduling.Mar_13_Rev__c = null;
        revScheduling.Apr_13_Rev__c = null;
        revScheduling.May_13_Rev__c = null;
        revScheduling.Jun_13_Rev__c = null;
        revScheduling.Jul_13_Rev__c = null;
        revScheduling.Aug_13_Rev__c = null;
        revScheduling.Sep_13_Rev__c = null;
        revScheduling.Oct_13_Rev__c = null;
        revScheduling.Nov_13_Rev__c = null; 
        revScheduling.Dec_13_Rev__c = null;
        revScheduling.Jan_14_Rev__c = null; 
        revScheduling.Feb_14_Rev__c = null;
        revScheduling.Mar_14_Rev__c = null;
        revScheduling.Apr_14_Rev__c = null;
        revScheduling.May_14_Rev__c = null;
        revScheduling.Jun_14_Rev__c = null;
        revScheduling.Jul_14_Rev__c = null;
        revScheduling.Aug_14_Rev__c = null;
        revScheduling.Sep_14_Rev__c = null;
        revScheduling.Oct_14_Rev__c = null;
        revScheduling.Nov_14_Rev__c = null; 
        revScheduling.Dec_14_Rev__c = null; 
        revScheduling.Jan_15_Rev__c = null; 
        revScheduling.Feb_15_Rev__c = null;
        revScheduling.Mar_15_Rev__c = null;
        revScheduling.Apr_15_Rev__c = null;
        revScheduling.May_15_Rev__c = null;
        revScheduling.Jun_15_Rev__c = null;
        revScheduling.Jul_15_Rev__c = null;
        revScheduling.Aug_15_Rev__c = null;
        revScheduling.Sep_15_Rev__c = null;
        revScheduling.Oct_15_Rev__c = null;
        revScheduling.Nov_15_Rev__c = null; 
        revScheduling.Dec_15_Rev__c = null; 
        revScheduling.Jan_16_Rev__c = null; 
        revScheduling.Feb_16_Rev__c = null;
        revScheduling.Mar_16_Rev__c = null;
        revScheduling.Apr_16_Rev__c = null;
        revScheduling.May_16_Rev__c = null;
        revScheduling.Jun_16_Rev__c = null;
        revScheduling.Jul_16_Rev__c = null;
        revScheduling.Aug_16_Rev__c = null;
        revScheduling.Sep_16_Rev__c = null;
        revScheduling.Oct_16_Rev__c = null;
        revScheduling.Nov_16_Rev__c = null; 
        revScheduling.Dec_16_Rev__c = null;
        revScheduling.Jan_17_Rev__c = null; 
        revScheduling.Feb_17_Rev__c = null;
        revScheduling.Mar_17_Rev__c = null;
        revScheduling.Apr_17_Rev__c = null;
        revScheduling.May_17_Rev__c = null;
        revScheduling.Jun_17_Rev__c = null;
        revScheduling.Jul_17_Rev__c = null;
        revScheduling.Aug_17_Rev__c = null;
        revScheduling.Sep_17_Rev__c = null;
        revScheduling.Oct_17_Rev__c = null;
        revScheduling.Nov_17_Rev__c = null; 
        revScheduling.Dec_17_Rev__c = null; 
        revScheduling.Jan_18_Rev__c = null; 
        revScheduling.Feb_18_Rev__c = null;
        revScheduling.Mar_18_Rev__c = null;
        revScheduling.Apr_18_Rev__c = null;
        revScheduling.May_18_Rev__c = null;
        revScheduling.Jun_18_Rev__c = null;
        revScheduling.Jul_18_Rev__c = null;
        revScheduling.Aug_18_Rev__c = null;
        revScheduling.Sep_18_Rev__c = null;
        revScheduling.Oct_18_Rev__c = null;
        revScheduling.Nov_18_Rev__c = null; 
        revScheduling.Dec_18_Rev__c = null;

        update revScheduling;
    }
    
    private static Set<OpportunityLineItemSchedule> CombineOppLineItemScheduleRevenueItems(OpportunityLineItemSchedule[] olis){
        System.Debug('OppLineItemScheduleRevenueController - Combining revenue months.');
        Set<String> olisMonthYearDates = new Set<String>();
        Set<OpportunityLineItemSchedule> olisSet = new Set<OpportunityLineItemSchedule>();
        for(OpportunityLineItemSchedule firstOlis: olis){
            System.Debug('OppLineItemScheduleRevenueController - Looping through months - ' + firstOlis.ScheduleDate.month() + '/' + firstOlis.ScheduleDate.year() + '.');
            if(!olisMonthYearDates.contains(firstOlis.ScheduleDate.month() + '-' + firstOlis.ScheduleDate.year())){
                OpportunityLineItemSchedule newOpp = firstOlis;
                for(OpportunityLineItemSchedule secondOlis: olis){
                    if(newOpp.Id != secondOlis.Id && newOpp.ScheduleDate.month() == secondOlis.scheduleDate.month() && newOpp.ScheduleDate.year() == secondOlis.scheduleDate.year()){
                        System.Debug('OppLineItemScheduleRevenueController - Found Revenue_Scheduling__c revenue month duplicate and merging.');
                        newOpp.Revenue = newOpp.Revenue + secondOlis.Revenue;
                    } 
                }
                System.Debug('OppLineItemScheduleRevenueController - Adding processed OpportunityLineItemSchedule for ' + newOpp.ScheduleDate.month() + '-' + newOpp.ScheduleDate.year() + '.');
                olisMonthYearDates.add(newOpp.ScheduleDate.month() + '-' + newOpp.ScheduleDate.year());
                olisSet.add(firstOlis);
            }
        }
        return olisSet;
    }
}