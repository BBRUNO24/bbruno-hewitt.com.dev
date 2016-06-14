public with sharing class SLDS_Toast {

	public Boolean showToast { get; set; }
    public String toastMsg{ get; set; }
    public SLDS_ToastEnum toastType { get; set; }

	public SLDS_Toast() {
		this.showToast = false;
		this.toastMsg = '';
		this.toastType = SLDS_ToastEnum.BASE;
	}
}