
class ToolbarViewModel : ViewModel {
    var activityInprogress = MutableLiveData(false)
    var backButtonVisible = MutableLiveData(false)
    var burgerButtonVisible = MutableLiveData(true)
    var leftButtonVisible = MutableLiveData(false)
    var rightButtonVisible = MutableLiveData(false)
    var titleVisible = MutableLiveData(true)
    var welcomeVisible = MutableLiveData(true)
    var btnDeleteItemVisible = MutableLiveData(false)
    var editingItemVisible = MutableLiveData(false)
}
