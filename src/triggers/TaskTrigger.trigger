/*
* Author: Nino Bustillos
* Description:
* History:
*     12Oct2016 NBustillos(DC): initial version
*/
trigger TaskTrigger on Task (after insert, after update) {
	TaskTriggerClass.afterEventHandler(trigger.new, trigger.oldMap, trigger.newMap);
}