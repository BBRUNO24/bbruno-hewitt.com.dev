public with sharing class ctlr_SLDS_TOAST {
	public SLDS_Toast myToast { get; set; }

	public String toastType { get{ return myToast.toastType.name(); } }

	public ctlr_SLDS_TOAST() {
		
	}
}