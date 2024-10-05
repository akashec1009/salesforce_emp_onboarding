import { LightningElement, track } from 'lwc';
import searchEmployeeById from '@salesforce/apex/EmployeeController.searchEmployeeById'

export default class SearchEmployeeComponent extends LightningElement {
    @track employeeData =[];
    @track error;
    empId = '';

    columns = [
        { label: 'Employee Name', fieldName: 'Name', type: 'text' },
        { label: 'Employee ID', fieldName: 'Employee_ID__c', type: 'text' },
        { label: 'Email', fieldName: 'Email__c', type: 'email' },
        { label: 'Department', fieldName: 'Department__c', type: 'text' }
    ];

    handleInputChange(event){
        this.empId = event.target.value;
    }

    handleSearch(){
        if(this.empId){
            searchEmployeeById({empId:this.empId})
            .then(result => {
                this.employeeData = [result];
                this.error = undefined;
            })
            .catch(error => {
                this.error = error.body.message;
                this.employeeData = [];
            });
        }else{
            this.error = 'Please enter the EmployeeID';
            this.employeeData =[];
        }
    }
    get isEmployeeFound(){
        return this.employeeData.length>0;
    }
    get isError(){
        return this.error != undefined;
    }
}