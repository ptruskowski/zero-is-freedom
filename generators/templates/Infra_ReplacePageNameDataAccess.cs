namespace ReplacePrefix

public class ReplacePageNameDataAccess : IGetReplacePageName, ISaveReplacePageName
{
    public ReplacePageNameDataAccess() {

    }

    public async Task<ReplacePageNameForm> GetAsync(ReplacePageNameForm? form = null) {
        await Task.Completed;

        // TODO Implement data access for retrieving

        return new ReplacePageNameForm();
    }

    public async Task<ReplacePageNameForm> SaveAsync(ReplacePageNameForm form) {
        await Task.Completed;

        // TODO Implement data access for saving

        return form;
    }
}