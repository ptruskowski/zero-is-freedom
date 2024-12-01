namespace ReplacePrefix.ReplacePageName

public interface ISaveReplacePageName
{
    Task<ReplacePageNameForm> SaveAsync(ReplacePageNameForm form);
}