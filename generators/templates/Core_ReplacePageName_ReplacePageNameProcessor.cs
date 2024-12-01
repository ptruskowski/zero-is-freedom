namespace ReplacePrefix.ReplacePageName

public class ReplacePageNameProcessor
{
    private readonly IGetReplacePageName _replacePageNameRetriever;
    private readonly ISaveReplacePageName _replacePageNameSaver;

    public ReplacePageNameProcessor(
        IGetReplacePageName replacePageNameRetriever,
        ISaveReplacePageName replacePageNameSaver
    ) {
        _replacePageNameRetriever = replacePageNameRetriever;
        _replacePageNameSaver = replacePageNameSaver;
    }

    public async Task<ReplacePageNameForm> GetAsync(ReplacePageNameForm? form = null) {
        // TODO implement
    }

    public async Task<ReplacePageNameForm> SaveAsync(ReplacePageNameForm form) {
        // TODO implement
    }
}