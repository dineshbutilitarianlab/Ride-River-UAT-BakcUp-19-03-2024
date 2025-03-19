import { LightningElement } from 'lwc';

export default class SideNavigationLWC extends LightningElement {
    selectedNav = 'default_recent';

    togglePanel() {
        let leftPanel = this.template.querySelector("div[data-my-id=leftPanel]");
        let rightPanel = this.template.querySelector("div[data-my-id=rightPanel]");

        if (leftPanel.classList.contains('slds-is-open')) {
            leftPanel.classList.remove("slds-is-open");
            leftPanel.classList.remove("open-panel");
            leftPanel.classList.add("slds-is-closed");
            leftPanel.classList.add("close-panel");
            rightPanel.classList.add("expand-panel");
            rightPanel.classList.remove("collapse-panel");
        } else {
            leftPanel.classList.add("slds-is-open");
            leftPanel.classList.add("open-panel");
            leftPanel.classList.remove("slds-is-closed");
            leftPanel.classList.remove("close-panel");
            rightPanel.classList.remove("expand-panel");
            rightPanel.classList.add("collapse-panel");
        }
    }

    refreshUserData(evt){
        const buttonIcon = evt.target.querySelector('.slds-button__icon');
        buttonIcon.classList.add('refreshRotate');

        setTimeout(() => {
            buttonIcon.classList.remove('refreshRotate');
        }, 1000);
    }

    handleSelect(event) {
        const selected = event.detail.name;
        this.selectedNav = selected;
    }
}