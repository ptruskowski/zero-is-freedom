namespace ReplacePrefix.ReplacePageName

public interface IGetReplacePageName
{
    Task<ReplacePageNameForm> GetAsync(ReplacePageNameForm? form = null);
}