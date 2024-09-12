public class FlowInvoker {
    
       @AuraEnabled public String email { get; set; }
       @AuraEnabled public List<Account> accountList { get; set; }
		
        public FlowInvoker(String email, List<Account> accountList) {
            this.email = email;
            this.accountList = accountList;
        }
        // Default no-arg constructor for Flow usage
        public FlowInvoker() {}
  }